RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_inc").
RUNONCEPATH("/orbit/node_alt").
RUNONCEPATH("/orbit/node_peri").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.


PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(100000, 90).
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    utilRemoveNodes().

    local t0 is time:seconds.
    LOCAL di IS -22.7.
    LOCAL ta to 50-ORBIT:ARGUMENTOFPERIAPSIS.

    set ta to utilAngleTo360(ta).
    local dt is utilDtTrue(ta).
    local t1 is t0+dt.

    local v is VELOCITYAT(SHIP, t1):orbit:mag.
    local nv is v * sin(di).
    local pv is v *(cos(di)-1).

    add node(t1, 0, nv, pv).

    orbitExecNode().

    updateMissionState("matchinc").
}

IF mission_state = "matchinc" {
    utilRemoveNodes().

    LOCAL ta to 53.

    local dt is utilDtTrue(ta).
    local t1 is time:seconds + dt.

    orbitNodeAlt(1492914, t1).

    orbitExecNode().

    updateMissionState("matchperi").
}

IF mission_state = "matchperi" {
    utilRemoveNodes().

    orbitNodePeri(7760691).
    orbitExecNode().

    updateMissionState("done").
}