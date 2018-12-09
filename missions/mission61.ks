RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").


SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(250000).
    mainframeCircularize().

    updateMissionState("Done").
}
