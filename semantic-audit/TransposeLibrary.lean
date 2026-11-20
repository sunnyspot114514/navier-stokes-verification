import Breakdown.CertCell.StatementDefs

open Breakdown

namespace IndependentTransposeCheck

/-- In ordinary Euclidean coordinates, coordinate j is the inner product of the
j-th column of K with z. This statement does not call a second transpose implementation. -/
theorem coordinateFormula (K : EuclideanSpace ℝ (Fin 3) →L[ℝ] EuclideanSpace ℝ (Fin 3))
    (z : EuclideanSpace ℝ (Fin 3)) (j : Fin 3) :
    Breakdown.AdjointDefect.transposeApply K z j =
      inner ℝ (K (EuclideanSpace.single j 1)) z := by
  simp [Breakdown.AdjointDefect.transposeApply, Breakdown.unitVector, Pi.single_apply]

#print axioms coordinateFormula

end IndependentTransposeCheck
