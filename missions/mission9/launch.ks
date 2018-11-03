RUNONCEPATH("/core/launch_ascent").
RUNONCEPATH("/orbit/circ").

PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    coreLaunchAscent().

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    PRINT "Launch sequence done. Begin circulating".
    orbitCirc().

    PRINT "Reached orbit. Conduct experiments.".

    updateMissionState("inorbit").
} ELSE IF mission_state = "inorbit" {
    RUNPATH("/core/fall_to_surface").

    updateMissionState("done").

    PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
}
