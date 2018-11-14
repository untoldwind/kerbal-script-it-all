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

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    utilRemoveNodes().

    LOCAL ta to 110.

    local dt is utilDtTrue(ta).
    local t1 is time:seconds + dt.

    orbitNodeAlt(2863334, t1).

    orbitExecNode().

    orbitNodePeri(2863334).

    orbitExecNode().
}