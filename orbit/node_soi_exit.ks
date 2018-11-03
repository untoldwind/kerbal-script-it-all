// Create manuvering node: Leave SOI
// Ship has to be in (nearly) circular orbit
// Parameters:
//   aeject: Angle of eject (body:prograde: +90 or body:retrograde: -90 escape orbit)
//   vhe: hyperbolic excess velocity

RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").

function orbitNodeSoiExit {
    parameter aeject, vhe.

    utilRemoveNodes().

    set ps to V(0,0,0) - body:position.
    set pc to body:body:position - body:position.
    // angular positions
    set ac to arctan2(pc:x,pc:z).
    set as0 to arctan2(ps:x,ps:z).
    // calculate deltav
    uiDebug( "T+" + round(missiontime) + " Periapsis maneuver, orbiting " + body:name).
    uiDebug( "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000) + "km -> soi excess " + round(vhe)).
    uiDebug( "T+" + round(missiontime) + " Periapsis: " + round(periapsis/1000) + "km").
    // present orbit properties
    set ra to BODY:RADIUS + (periapsis+apoapsis)/2.  // average radius (burn angle not yet known)
    set vom to velocity:orbit:mag.          // actual velocity
    set r to BODY:RADIUS + altitude.                 // actual distance to body
    set va to sqrt( vom^2 - 2*BODY:MU*(1/ra - 1/r) ). // average velocity 
    // after burn velocity for desired velocity at soi 
    set v2 to sqrt(vhe^2 - 2*BODY:MU*(1/BODY:SOIRADIUS - 1/ra)).
    set deltav to v2 - va.
    uiDebug( "T+" + round(missiontime) + " Periapsis burn: " + round(va) + ", dv:" + round(deltav) + " -> " + round(v2) + "m/s").
    // calculate burn angle (see also http://www.braeunig.us/space/orbmech.htm#hyperbolic)
    set soe to v2^2/2 - BODY:MU/ra.              // specific orbital energy
    set h to ra * v2.
    set e to sqrt(1+(2*soe*(h/BODY:MU)^2)).      // eccentricity of hyperbolic orbit
    set tai to arccos(-1/e).                // angle between the periapsis vector and the departure asymptote
    set sma to -BODY:MU/(2*soe).
    set ip to -sma/tan(arcsin(1/e)).        // impact parameter 
    set aip to arctan(ip/BODY:SOIRADIUS).              // angle to turn leaving mun soi point on mun orbit
    set asoi to tai - aip.
    set aburn to ac + aeject + asoi.
    set sma to (periapsis + 2*BODY:RADIUS + apoapsis)/2. // semi major axis present orbit
    set ops to 2 * CONSTANT:PI * sqrt(sma^3/BODY:MU).      // ship orbital period
    until aburn < as0 { set aburn to aburn - 360. }
    set soiEta to (as0 - aburn)/360 * ops.
    if soiEta < 60 { 
        set soiEta to soiEta + ops.
        uiDebug( "T+" + round(missiontime) + " too close for maneuver, waiting for one orbit, " + round(ops/60,1) + "m").
    }
    uiDebug( "T+" + round(missiontime) + " ship, orbital period: " + round(ops/60,1) + "m").
    uiDebug( "T+" + round(missiontime) + " | now: " + round(as0) + "', maneuver: " + round(aburn) + "' in " + round(soiEta/60,1) + "m").
    set nd to node(time:seconds + soiEta, 0, 0, deltav).
    add nd.
    uiDebug( "T+" + round(missiontime) + " Node created.").
}