RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_inc").
RUNONCEPATH("/orbit/node_peri").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.


PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(100000, -90).
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    utilRemoveNodes().
    
    local t0 is time:seconds.
    LOCAL di IS 63.4.
    LOCAL ta is 112.
  
    set ta to utilAngleTo360(ta).
    local dt is utilDtTrue(ta).
    local t1 is t0+dt.

    local v is VELOCITYAT(SHIP, t1):orbit:mag.
    local nv is v * sin(di).
    local pv is v *(cos(di)-1).

    add node(t1, 0, nv, pv).

    orbitExecNode().

    updateMissionState("matchedinc").
}

IF mission_state = "matchedinc" {
    orbitNodePeri(3060027).

    orbitExecNode().

    updateMissionState("matchap").
}

IF mission_state = "matchap" {
    utilRemoveNodes().
    orbitNodePeri(103500).

    orbitExecNode().

    updateMissionState("done").
}
