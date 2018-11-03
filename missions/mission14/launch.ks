PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    RUNPATH("/core/launch_ascent").

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    PRINT "Launch sequence done. Begin circulating".
    RUNPATH("/orbit/circ").

    PRINT "Reached orbit.".

    updateMissionState("inorbit").
} 

IF mission_state = "inorbit" {
    SET TARGET TO "Mun".
    RUNPATH("/orbit/node_hoh").
    RUNPATH("/orbit/exec_node").

    PRINT "In transfer to Mun".

    updateMissionState("intransfer").
}

IF mission_state = "intransfer" {
    RUNPATH("/orbit/transfer").

    updateMissionState("circulating_target").
}

IF mission_state = "circulating_target" {
    PRINT "Reached Mun circulating".
    RUNPATH("/orbit/circ").

    PRINT "Reached orbit.".

    updateMissionState("at_target").
}

IF mission_state = "at_target" {
    PRINT "Do return".
    RUNPATH("/orbit/return_from_moon", 800000).
}
