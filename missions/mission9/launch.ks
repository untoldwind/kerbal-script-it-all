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

    PRINT "Reached orbit. Conduct experiments.".

    updateMissionState("inorbit").
} ELSE IF mission_state = "inorbit" {
    RUNPATH("/core/fall_to_surface").

    updateMissionState("done").

    PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
}
