import Lean

open Lean

namespace ProofRoutes

def fromProject (env : Environment) (n : Name) : Bool := Id.run do
  let some i := env.getModuleIdxFor? n | return false
  let some m := env.header.modules[i.toNat]? | return false
  return (`Breakdown).isPrefixOf m.module || m.module == `Solution

def dependencies (env : Environment) (n : Name) : Array Name := Id.run do
  let some info := env.find? n | return #[]
  let mut a := info.type.getUsedConstants
  if let some v := info.value? true then a := a ++ v.getUsedConstants
  match info with
  | .inductInfo d => a := a ++ d.ctors.toArray ++ d.all.toArray
  | .ctorInfo d => a := a.push d.induct
  | .recInfo d =>
    for r in d.rules do a := (a.push r.ctor) ++ r.rhs.getUsedConstants
  | _ => pure ()
  return a.filter (fromProject env)

def sentinels : Array Name := #[
  `Breakdown.BreakdownOnSpace, `Breakdown.BreakdownOnTorus,
  `Breakdown.extended_certificate_orbit_proved, `Breakdown.FarField.breakdownOnTorus_of_weak,
  `Breakdown.breakdownOnSpace_of_weak, `Breakdown.CellLayerSystem.isExtendedCertificate_of_parts,
  `Breakdown.IsSmoothSolution, `Breakdown.PeriodicSimilarityProfileExists,
  `Breakdown.WeakPeriodicSimilarityProfileExists,
  `Breakdown.FractionalBreakdownOnSpace, `Breakdown.FractionalBreakdownOnTorus,
  `Breakdown.fractional_breakdown_on_space, `Breakdown.fractional_breakdown_on_torus,
  `Breakdown.CellCert.CellSystem.fractional_breakdown_of_cell_system_proved]

def trace (env : Environment) (cache : IO.Ref (Std.HashMap Name (Array Name))) (root : Name) : IO Json := do
  if (env.find? root).isNone then throw (IO.userError s!"Unknown root {root}")
  let mut todo := #[root]
  let mut parents : Std.HashMap Name Name := ({} : Std.HashMap Name Name).insert root root
  let mut i := 0
  let mut proofBodies := 0
  let mut projectAxioms : Array String := #[]
  while i < todo.size do
    let n := todo[i]!
    i := i+1
    if let some info := env.find? n then
      match info with
      | .axiomInfo _ => projectAxioms := projectAxioms.push n.toString
      | .thmInfo _ => proofBodies := proofBodies+1
      | _ => pure ()
    let adjacent ← match (← cache.get)[n]? with
      | some v => pure v
      | none => do
        let v := dependencies env n
        cache.modify (·.insert n v)
        pure v
    for k in adjacent do
      if !parents.contains k then
        parents := parents.insert k n
        todo := todo.push k
  let mut found := #[]
  for n in sentinels do
    if parents.contains n then
      let mut path := [n.toString]
      let mut current := n
      while current != root do
        current := parents[current]!
        path := current.toString :: path
      found := found.push <| Json.mkObj [("declaration",toJson n.toString),("one_path",toJson path)]
  return Json.mkObj [("root",toJson root.toString),("project_declarations",toJson parents.size),
    ("project_theorem_bodies",toJson proofBodies),("project_axioms",toJson projectAxioms),("named_hits",Json.arr found)]

def go : IO Unit := do
  initSearchPath (← findSysroot)
  let env ← importModules #[{module := `Solution}] {}
  let cache ← IO.mkRef ({} : Std.HashMap Name (Array Name))
  let mut rows := #[]
  for root in #[`Breakdown.breakdown_on_space, `Breakdown.breakdown_on_torus,
      `Breakdown.CellLayerSystem.breakdownOnSpaceAndTorus_of_cell_system_condition,
      `Breakdown.CellCert.CellSystem.fractional_breakdown_of_cell_system] do
    rows := rows.push (← trace env cache root)
  IO.println (Json.mkObj [("roots",Json.arr rows),("sentinels",toJson (sentinels.map Name.toString))]).compress

end ProofRoutes

def main : IO Unit := ProofRoutes.go
