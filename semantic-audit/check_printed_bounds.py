#!/usr/bin/env python3
"""Check the printed scalar implications on p. 70 by rational interval bounds."""
from fractions import Fraction as Q
import json

# Equations (7.15), (7.20)-(7.21), (7.25), (7.27), and (B.22).
# B.1 gives c_M^2 >= 50/3, so c1 >= 50/3.
w = Q(39,50)
sqrt_w_upper = Q(8832,10000)
pi_upper = Q(22,7)
c1_min = Q(50,3)
c0_squared_min = Q(50,3)*400*(1+Q(1,2**18))
c2_squared_min = Q(1000*50,3)
c0_claim = Q("81.64")
c2_claim = Q(129)
cL_lower = c1_min+c0_claim
M_cap = Q("0.01695")
eps_cap = Q("0.0075")

checks = {
    "sqrt_w_upper_squared_exceeds_w":sqrt_w_upper**2>w,
    "c0_above_81.64":c0_squared_min>c0_claim**2,
    "c2_above_129":c2_squared_min>c2_claim**2,
    "cL_above_98.3":cL_lower>Q("98.3"),
    "M_below_0.01695":pi_upper*sqrt_w_upper<(M_cap*cL_lower)**2,
    "epsilon_below_0.0075":M_cap*sqrt_w_upper/2<eps_cap
}
if not all(checks.values()): raise ValueError(checks)
print(json.dumps({"scope":"Conditional implications between printed scalar bounds; no certificate inputs read.",
                  "pi_upper":"22/7","sqrt_39_over_50_upper":str(sqrt_w_upper),
                  "c0_squared_lower":str(c0_squared_min),"c2_squared_lower":str(c2_squared_min),
                  "cL_lower":str(cL_lower),"checks":checks},indent=2))
