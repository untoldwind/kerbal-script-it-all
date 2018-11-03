// Change inclination of orbit.
//
// Parameters:
//    inclination the desired inclination

RUNONCEPATH("/core/lib_util").

function orbitNodeInc {
    parameter inclination is 0.
    
    LOCAL i0 is ORBIT:inclination.
    LOCAL di IS inclination-i0.
    LOCAL ta to -ORBIT:ARGUMENTOFPERIAPSIS.

    set ta to utilAngleTo360(ta).
    if ta < ORBIT:trueAnomaly { set ta to ta+180. set di to -di. }
    local dt is utilDtTrue(ta).
    local t1 is t0+dt.

    local v is VELOCITYAT(SHIP, t1):orbit:mag.
    local nv is v * sin(di).
    local pv is v *(cos(di)-1).

    add node(t1, 0, nv, pv).
}