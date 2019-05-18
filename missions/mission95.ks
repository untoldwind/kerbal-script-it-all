RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/vac2/lib").

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.

    PRINT "Launch sequence".
    vacLaunchAscent(60000).
    mainframeCircularize().

    updateMissionState("in_orbit_minmus").
}
