RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_inc_tgt").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/transfer").

PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent().

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    PRINT "Launch sequence done. Begin circulating".
    orbitCirc().

    PRINT "Reached orbit.".

    updateMissionState("inorbit").
} 

IF mission_state = "inorbit" {
    SET TARGET TO Minmus.
    orbitNodeIncTgt().
    orbitExecNode().

    updateMissionState("matchedinc").
}

IF mission_state = "matchedinc" {
    orbitNodeHoh().
    orbitExecNode().

    updateMissionState("intransfer").
}

IF mission_state = "intransfer" {
    orbitTransfer().

    updateMissionState("circulating_target").
}

IF mission_state = "circulating_target" {
    PRINT "Reached Mun circulating".
    orbitCirc().

    PRINT "Reached orbit.".

    updateMissionState("at_target").

    PRINT "You may now enjoy the view".
} 
