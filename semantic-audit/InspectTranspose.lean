import Lean
open Lean

def main (args : List String) : IO Unit := do
  initSearchPath (← findSysroot)
  let mod := (args[0]!).toName
  let n := `Breakdown.AdjointDefect.transposeApply
  let env ← importModules #[{module := mod}] {}
  let some (.defnInfo d) := env.find? n | throw (IO.userError "Definition unavailable")
  let hint := match d.hints with
    | .opaque => "opaque"
    | .abbrev => "abbrev"
    | .regular k => s!"regular {k}"
  IO.println s!"type = {d.type}"
  IO.println s!"value = {d.value}"
  IO.println s!"dependencies = {d.value.getUsedConstants}"
  IO.println s!"height = {hint}"
  IO.println s!"level parameters = {d.levelParams}; all = {d.all}"
