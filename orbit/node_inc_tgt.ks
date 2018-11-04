// Match inclinations with target by planning a burn at the ascending or
// descending node, whichever comes first.

RUNONCEPATH("/core/lib_util").

function orbitNodeIncTgt {
    local t0 is time:seconds.
    local i1 is target:orbit:inclination.
    local sp is ship:position-body:position.
    local tp is target:position-body:position.
    local sv is ship:velocity:orbit.
    local tv is target:velocity:orbit.
    local sn is vcrs(sv, sp). // our normal vector
    local tn is vcrs(tv, tp). // its normal vector
    local ln is vcrs(tn, sn). // from AN to DN

    local di is vang(sn, tn).
    local ta is vang(sp, ln).
    
    if vang(vcrs(sp,ln),sn) < 90 set ta to -ta.
    set ta to ta + orbit:trueAnomaly.

    set ta to utilAngleTo360(ta).
    if ta < ORBIT:trueAnomaly { set ta to ta+180. set di to -di. }
    local dt is utilDtTrue(ta).
    local t1 is t0+dt.

    local v is VELOCITYAT(SHIP, t1):orbit:mag.
    local nv is v * sin(di).
    local pv is v *(cos(di)-1).

    add node(t1, 0, nv, pv).
}