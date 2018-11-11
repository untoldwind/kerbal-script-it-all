// Create manuvering node: Return from moon
// Parameters:
//   tgtperi: Desired periasis of parent body

RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/orbit/node_soi_exit").

function orbitNodeReturnFromMoon {
    parameter tgtperi.

    // setup a Hohmann transfer orbit from Mun/Minmus to Kerbin
    // prerequisite: ship in circular orbit
    uiDebug( "T+" + round(missiontime) + " Hohmann transfer to Kerbin, orbiting " + body:name).
    // move origin to central body (i.e. Kerbin)
    set ps to V(0,0,0) - body:position.
    set pk to body:body:position - body:position.
    // hohmann orbit properties, s: ship, m: mun, 0: mun orbit, 1: hohmann transfer, 2: earth orbit
    // major semi axis
    set sma1 to pk:mag.
    set smah to ( pk:mag + tgtperi )/2.
    set vmun to sqrt(body:body:mu / pk:mag).   // Mun's orbital velocity
    set vh to sqrt(vmun^2 - body:body:mu * (1/smah - 1/sma1)). // Hohmann velocity
    set vhe to vmun - vh.                   // hyperbolic excess velocity
    uiDebug( "T+" + round(missiontime) + " " + body:name + ": " + round(vmun) + ", Hohmann: " + round(vh) + " m/s").
    uiDebug( "T+" + round(missiontime) + " Hyperbolic excess: " + round(vhe) + " m/s").
    set aeject to -90.
    if body:name = "Minmus" {
        set aeject to -90.
    }
    uiDebug( "T+" + round(missiontime) + " Ejection angle " + round(aeject) + " deg").

    orbitNodeSoiExit(aeject, vhe).
}