import Lean

open Lean

namespace SemanticInterfaces

deriving instance BEq for QuotKind
deriving instance BEq for QuotVal
deriving instance BEq for InductiveVal
deriving instance BEq for ConstantInfo

def owner (e : Environment) (n : Name) : Name := Id.run do
  let some i := e.getModuleIdxFor? n | return .anonymous
  let some m := e.header.modules[i.toNat]? | return .anonymous
  return m.module

def project (e : Environment) (n : Name) : Bool := Id.run do
  let m := owner e n
  return (`Breakdown).isPrefixOf m || [`Solution, `Challenge, `CellLayerChallenge,
    `CellLayerTheorems, `ExtendedCoerciveChallenge, `CoerciveChallenge,
    `CertificateChallenge, `ExtendedCertificateChallenge, `FractionalChallenge,
    `FractionalCertificateChallenge, `FractionalCellSystemChallenge].contains m

def refs (v : ConstantInfo) (useTheoremBodies : Bool) : Array Name := Id.run do
  let mut a := v.type.getUsedConstants
  match v with
  | .thmInfo t => if useTheoremBodies then a := a ++ t.value.getUsedConstants
  | .defnInfo d => a := a ++ d.value.getUsedConstants
  | .opaqueInfo d => a := a ++ d.value.getUsedConstants
  | .inductInfo d => a := a ++ d.ctors.toArray ++ d.all.toArray
  | .ctorInfo d => a := a.push d.induct
  | .recInfo d =>
    a := a ++ d.all.toArray
    for r in d.rules do a := (a.push r.ctor) ++ r.rhs.getUsedConstants
  | _ => pure ()
  return a

def hintString : ReducibilityHints → String
  | .opaque => "opaque"
  | .abbrev => "abbrev"
  | .regular k => s!"regular {k}"

def defEq (e : Environment) (a b : Expr) : String :=
  if a == b then "identical" else
    match Kernel.isDefEq e {} a b with
    | .ok true => "yes"
    | .ok false => "no"
    | .error _ => "kernel_error"

def only (a b : Array Name) : Array String :=
  ((a.filter fun n => !b.contains n).map Name.toString).qsort (· < ·)

def compareDecls (e₁ e₂ : Environment) (n : Name) (v w : ConstantInfo) : Json := Id.run do
  let mut fields := [
    ("name", toJson n.toString), ("long_module", toJson (owner e₁ n).toString),
    ("library_module", toJson (owner e₂ n).toString),
    ("type_exact", toJson (v.type == w.type)),
    ("type_defeq_long", toJson (defEq e₁ v.type w.type)), ("type_defeq_library", toJson (defEq e₂ v.type w.type)),
    ("levels_equal", toJson (v.levelParams == w.levelParams))]
  if let .defnInfo d₁ := v then
    if let .defnInfo d₂ := w then
      let changedHintsOnly := ConstantInfo.defnInfo {d₁ with hints := d₂.hints} == w
      fields := fields ++ [("only_hint_differs", toJson changedHintsOnly),
        ("long_hint", toJson (hintString d₁.hints)), ("library_hint", toJson (hintString d₂.hints)),
        ("metadata_equal_with_body_replaced", toJson (ConstantInfo.defnInfo {d₁ with value := d₂.value} == w))]
  match v.value? true, w.value? true with
  | some a, some b =>
    fields := fields ++ [("value_exact",toJson (a == b)),
      ("value_defeq_long",toJson (defEq e₁ a b)),("value_defeq_library",toJson (defEq e₂ a b)),
      ("refs_only_long",toJson (only a.getUsedConstants b.getUsedConstants)),
      ("refs_only_library",toJson (only b.getUsedConstants a.getUsedConstants))]
  | _, _ => pure ()
  return Json.mkObj fields

def rootNames : Array Name := #[
  `Breakdown.CellLayerSystem.breakdownOnSpace_of_cell_system_condition,
  `Breakdown.CellLayerSystem.breakdownOnTorus_of_cell_system_condition,
  `Breakdown.CellLayerSystem.breakdownOnSpaceAndTorus_of_cell_system_condition]

def installProofs (target source : Environment) (names : Array String) : IO (Environment × Array Json) := do
  let mut env := target
  let mut pending := names.map String.toName
  let mut added := #[]
  for _ in [:names.size+1] do
    let mut later := #[]
    for n in pending do
      let some (.thmInfo th) := source.find? n | throw (IO.userError s!"One-sided declaration is not a theorem: {n}")
      let axs ← (collectAxioms n : CoreM (Array Name)).toIO'
        {fileName := "<semantic-audit>", fileMap := default} {env := source}
      if !axs.all (fun a => #[`propext, `Quot.sound, `Classical.choice].contains a) then
        throw (IO.userError s!"Unapproved helper axiom: {n}, {axs}")
      match env.addDeclCore 0 100000 (.thmDecl th) none (doCheck := true) with
      | .ok accepted =>
        env := accepted
        let pretty ← (Meta.ppExpr th.type).run' |>.toIO'
          {fileName := "<semantic-audit>", fileMap := default} {env := source}
        added := added.push (Json.mkObj [("name",toJson n.toString),("type",toJson pretty.pretty),
          ("axioms",toJson (axs.map Name.toString)),("recipient_kernel_checked_original_proof",toJson true)])
      | .error _ => later := later.push n
    if later.isEmpty then return (env,added)
    if later.size == pending.size then
      throw (IO.userError s!"Could not kernel-check original proofs in recipient: {later}")
    pending := later
  throw (IO.userError "Helper replay did not finish")

def replaceProofNames (as : Std.HashMap Name Name) (e : Expr) : Expr :=
  e.replace fun x => match x with
    | .const n us => (as[n]?).map fun k => mkConst k us
    | _ => none

def compareModuloProofNames (left right : Environment) (onlyL onlyR : Array String)
    (changed : Array Name) : IO Json := do
  let (fullL,addedL) ← installProofs left right onlyR
  let (fullR,addedR) ← installProofs right left onlyL
  let mut canonical : Std.HashMap Name Name := {}
  let mut reps : Array Name := #[]
  let mut candidates := (onlyL++onlyR).map String.toName
  for n in changed do
    let some (.defnInfo a) := left.find? n | throw (IO.userError s!"Unexpected difference kind: {n}")
    let some (.defnInfo b) := right.find? n | throw (IO.userError s!"Unexpected difference kind: {n}")
    let la := a.value.getUsedConstants
    let rb := b.value.getUsedConstants
    for p in la do
      if !rb.contains p && !candidates.contains p then candidates := candidates.push p
    for p in rb do
      if !la.contains p && !candidates.contains p then candidates := candidates.push p
  let mut aliases := #[]
  for n in candidates do
    let some (.thmInfo curr) := fullL.find? n | throw (IO.userError s!"Missing theorem {n}")
    let some (.thmInfo peer) := fullR.find? n | throw (IO.userError s!"Non-theorem difference {n}")
    if curr.type != peer.type || curr.levelParams != peer.levelParams then
      throw (IO.userError s!"Auxiliary proposition differs between environments: {n}")
    let original := if (left.find? n).isSome then left else right
    let axs ← (collectAxioms n : CoreM (Array Name)).toIO'
      {fileName := "<semantic-audit>", fileMap := default} {env := original}
    if !axs.all (fun a => #[`propext, `Quot.sound, `Classical.choice].contains a) then
      throw (IO.userError s!"Unapproved auxiliary axiom: {n}, {axs}")
    let pretty ← (Meta.ppExpr curr.type).run' |>.toIO'
      {fileName := "<semantic-audit>", fileMap := default} {env := fullL}
    let r := reps.find? fun key => match fullL.find? key with
      | some (.thmInfo prev) => prev.type == curr.type && prev.levelParams == curr.levelParams
      | _ => false
    let key := r.getD n
    if r.isNone then reps := reps.push n
    canonical := canonical.insert n key
    aliases := aliases.push <| Json.mkObj [("name",toJson n.toString),("canonical_proof",toJson key.toString),
      ("common_proposition",toJson pretty.pretty),("axioms",toJson (axs.map Name.toString))]
  let mut comparisons := #[]
  let mut allPassed := true
  for n in changed do
    let some (.defnInfo a) := left.find? n | throw (IO.userError s!"Unexpected difference kind: {n}")
    let some (.defnInfo b) := right.find? n | throw (IO.userError s!"Unexpected difference kind: {n}")
    let metadata := ConstantInfo.defnInfo {a with value := b.value} == ConstantInfo.defnInfo b
    let normalized := replaceProofNames canonical a.value == replaceProofNames canonical b.value
    let l := Kernel.isDefEqGuarded fullL {} a.value b.value
    let r := Kernel.isDefEqGuarded fullR {} a.value b.value
    allPassed := allPassed && metadata && normalized && l && r
    comparisons := comparisons.push <| Json.mkObj [("name",toJson n.toString),
      ("type_and_metadata_equal",toJson metadata),("same_expression_after_proof_names_only",toJson normalized),
      ("kernel_defeq_in_long",toJson l),("kernel_defeq_in_library",toJson r)]
  return Json.mkObj [("all_checks_passed",toJson allPassed),("differences_rechecked",toJson changed.size),
    ("helpers_kernel_checked_in_long",Json.arr addedL), ("helpers_kernel_checked_in_library",Json.arr addedR),
    ("proof_type_class_count",toJson reps.size),("proof_aliases", Json.arr aliases),
    ("unequal_control_rejected_in_both", toJson (!(Kernel.isDefEqGuarded fullL {} (mkNatLit 0) (mkNatLit 1)) && !(Kernel.isDefEqGuarded fullR {} (mkNatLit 0) (mkNatLit 1)))),("results",Json.arr comparisons)]

def inspectRoots (left right : Environment) : IO Json := do
  let mut todo := rootNames
  let mut seen : Std.HashSet Name := {}
  let mut changed : Array Json := #[]
  let mut changedNames : Array Name := #[]
  let mut leftOnly : Array String := #[]
  let mut rightOnly : Array String := #[]
  let mut rootRows : Array Json := #[]
  let mut common := 0
  let mut i := 0
  while i < todo.size do
    let n := todo[i]!
    i := i+1
    if seen.contains n then continue
    seen := seen.insert n
    let va := left.find? n
    let vb := right.find? n
    let isTarget := rootNames.contains n
    let mut neighbors := #[]
    for ov in #[va,vb] do
      if let some v := ov then
        neighbors := neighbors ++ (if isTarget then v.type.getUsedConstants else refs v true)
    for k in neighbors do
      if !(seen.contains k) && (project left k || project right k) then todo := todo.push k
    match va, vb with
    | some a, some b =>
      common := common+1
      if isTarget then
        rootRows := rootRows.push <| Json.mkObj [("name",toJson n.toString),
          ("type_and_universes_identical",toJson (a.toConstantVal == b.toConstantVal))]
      else if a != b then
        changed := changed.push (compareDecls left right n a b)
        changedNames := changedNames.push n
    | some _, none => leftOnly := leftOnly.push n.toString
    | none, some _ => rightOnly := rightOnly.push n.toString
    | none, none => throw (IO.userError s!"Unknown worklist name {n}")
  let checkedProofs ← compareModuloProofNames left right leftOnly rightOnly changedNames
  return Json.mkObj [("after_checking_proof_names", checkedProofs), ("targets", Json.arr rootRows), ("reachable_project_names",toJson seen.size),
    ("common_project_declarations",toJson common), ("changed_common_declarations",Json.arr changed),
    ("only_long",toJson leftOnly),("only_library",toJson rightOnly)]

def tracedNames : Array Name := #[`Breakdown.BreakdownOnSpace, `Breakdown.BreakdownOnTorus,
  `Breakdown.PeriodicSimilarityProfileExists, `Breakdown.WeakPeriodicSimilarityProfileExists,
  `Breakdown.ExtendedCertificateHypothesis, `Breakdown.IsExtendedCertificate,
  `Breakdown.CellLayerSystem.CertificateClauses, `Breakdown.ExtendedCertificateData,
  `Breakdown.CellLayerSystem.CellSystemCondition]

def premiseReach (env : Environment) (root : Name) : IO Json := do
  let mut todo := #[root]
  let mut seen : Std.HashSet Name := {}
  let mut i := 0
  while i < todo.size do
    let n := todo[i]!
    i := i+1
    if seen.contains n then continue
    seen := seen.insert n
    let some v := env.find? n | throw (IO.userError s!"Unknown premise dependency {n}")
    for k in refs v false do
      if !seen.contains k && project env k then todo := todo.push k
  return Json.mkObj [("root",toJson root.toString),("reachable_project_names",toJson seen.size),
    ("named_hits",toJson ((tracedNames.filter seen.contains).map Name.toString))]

def audit : IO Unit := do
  initSearchPath (← findSysroot)
  let left ← importModules #[{module := `CellLayerChallenge}] {}
  let right ← importModules #[{module := `CellLayerTheorems}] {}
  let comparison ← inspectRoots left right
  let mut premises := #[]
  for n in #[`Breakdown.CellLayerSystem.CellSystemCondition, `Breakdown.ExtendedCertificateHypothesis,
      `Breakdown.PeriodicSimilarityProfileExists, `Breakdown.WeakPeriodicSimilarityProfileExists] do
    premises := premises.push (← premiseReach right n)
  IO.println (Json.mkObj [("comparison",comparison),("premise_reachability",Json.arr premises)]).compress

end SemanticInterfaces

def main : IO Unit := SemanticInterfaces.audit
