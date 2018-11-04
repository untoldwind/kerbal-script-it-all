RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/atmo/deorbit_simple").
RUNONCEPATH("/orbit/circ").

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

    PRINT "Reached orbit. Conduct experiments.".

    updateMissionState("inorbit").
} ELSE IF mission_state = "inorbit" {
    atmoDeorbitSimple().

    updateMissionState("done").

    PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
}
