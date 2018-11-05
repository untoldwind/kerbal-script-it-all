RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_inc").
RUNONCEPATH("/orbit/node_alt").
RUNONCEPATH("/orbit/node_peri").
RUNONCEPATH("/core/lib_util").

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(90000, -90).
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    orbitNodeInc(180).
    orbitExecNode().

    updateMissionState("matchedinc").
}

IF mission_state = "matchedinc" {
    LOCAL dAngle IS utilAngleTo360(200 + SHIP:ORBIT:LAN).
    LOCAL dt IS SHIP:ORBIT:PERIOD * dAngle / 360.

    print dAngle.
    print dt.

    orbitNodeAlt(9643328, time:seconds + dt).
    orbitExecNode().

    updateMissionState("intransit").
}

IF mission_state = "intransit" {
    orbitNodePeri(8893355).
    orbitExecNode().

    updateMissionState("done").
}

// 9643328
// 8893355