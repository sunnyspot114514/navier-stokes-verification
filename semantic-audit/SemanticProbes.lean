import Solution
import Mathlib.Analysis.Calculus.Deriv.Abs

open Breakdown MeasureTheory
open scoped ContDiff ENNReal BigOperators

namespace SemanticAudit

/-- The physical equation in the audited solution has zero external force. -/
theorem unforcedMomentum {ν : ℝ} {u₀ : Space → Space}
    {u : ℝ → Space → Space} {p : ℝ → Space → ℝ} (h : IsSmoothSolution ν u₀ u p)
    {t : ℝ} (ht : 0 < t) (x : Space) :
    deriv (fun s => u s x) t + fderiv ℝ (u t) x (u t x) + gradientAt (p t) x =
      ν • ∑ i : Fin 3, iteratedFDeriv ℝ 2 (u t) x ![unitVector i, unitVector i] := by
  change deriv (fun s => u s x) t + advectionAt (u t) x + gradientAt (p t) x =
    ν • sumSecondPartialsAt (u t) x
  rw [h.momentum t ht x]
  abel

/-- The parameter tests cannot all be vacuous through an empty admissible set. -/
theorem centreAdmissible {k : ℕ} {d : ExtendedCertificateData k} (h : IsExtendedCertificate d) :
    (0 : Fin k → ℝ) ∈ d.params :=
  CoerciveWeak.zero_mem_params d h.radius_nonneg

/-- The strict nontriviality test prevents the zero approximate profile at the centre. -/
theorem centreProfileNotZero {k : ℕ} {d : ExtendedCertificateData k} (h : IsExtendedCertificate d) :
    d.profile (0 : Fin k → ℝ) ≠ (fun _ _ => (0 : Space)) := by
  intro hz
  have hn := h.nontrivial 0 (centreAdmissible h)
  have hnonneg : 0 ≤ 4 * d.sizeBound ^ 2 / d.weight :=
    div_nonneg (mul_nonneg (by norm_num) (sq_nonneg _)) h.weight_pos.le
  simp [hz, periodLIntegral, matSq] at hn
  exact (not_lt_of_ge hnonneg) hn

/-- The orthogonality and norm cap in the paper's row clause allow a single zero row. -/
theorem zeroRowMeetsPaperRowClause :
    (∀ i j : Fin 1, i ≠ j →
      periodPairing (fun _ _ => (0 : Space)) (fun _ _ => (0 : Space)) = 0) ∧
    periodNorm (fun _ _ => (0 : Space)) ≤ 1 := by
  constructor
  · intro i j _
    simp [periodPairing]
  · simp [periodNorm, periodLIntegral]

/-- A present row in the *same encoding* cannot be zero in an extended Lean certificate. -/
theorem certifiedRowNotZero {k : ℕ} {d : ExtendedCertificateData k} (h : IsExtendedCertificate d)
    (i : Fin d.rowCount) : d.rowField i ≠ (fun _ _ => (0 : Space)) := by
  intro hz
  have hn := h.rowField_orthonormal i i
  simp [hz, periodPairing] at hn

/-- Continuity in a parameter alone cannot supply the derivative in that parameter. -/
theorem continuityDoesNotGiveParameterDerivative :
    Continuous (abs : ℝ → ℝ) ∧ ¬ DifferentiableAt ℝ (abs : ℝ → ℝ) 0 :=
  ⟨continuous_abs, not_differentiableAt_abs_zero⟩

/-- The cell-to-certificate step is allowed to change the decay bound alone. -/
theorem decayUpdatePreservesWitnessFields {k : ℕ} (d : ExtendedCertificateData k) (b : ℝ) :
    let d' := {d with decay := b}
    d'.profile = d.profile ∧ d'.period = d.period ∧ d'.symmetries = d.symmetries ∧
      d'.pressureGrad = d.pressureGrad ∧ d'.actuator = d.actuator := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- A certificate gives a smooth profile and the two qualitative breakdown conclusions.
The concrete certificate remains an explicit hypothesis. -/
theorem certificateToSmoothAndBreakdown (h : ExtendedCertificateHypothesis) :
    PeriodicSimilarityProfileExists ∧ BreakdownOnSpace ∧ BreakdownOnTorus := by
  have weak := extended_certificate_orbit h
  exact ⟨FarField.periodicLerayProfileExists_of_weak weak,
    breakdown_on_space_of_weak weak, FarField.breakdownOnTorus_of_weak weak⟩

#print axioms unforcedMomentum
#print axioms centreAdmissible
#print axioms centreProfileNotZero
#print axioms zeroRowMeetsPaperRowClause
#print axioms certifiedRowNotZero
#print axioms continuityDoesNotGiveParameterDerivative
#print axioms decayUpdatePreservesWitnessFields
#print axioms certificateToSmoothAndBreakdown

end SemanticAudit
