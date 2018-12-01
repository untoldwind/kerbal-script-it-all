RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(100000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    mainframeReturnFromMoon(11522716738).

    updateMissionState("leaving_soi").

}

IF mission_state = "leaving_soi" {
    mainframeTransfer().

    updateMissionState("left_soi").
}

IF mission_state = "left_soi" {
    mainframeChangePeriapsis(11522716738).

    mainframeChangeApoapsis(11479486369, TIME + ETA:PERIAPSIS, false).
    updateMissionState("changed_pe").
} ELSE IF mission_state = "changed_pe" {
    mainframeChangeApoapsis(11479486369, TIME + ETA:PERIAPSIS, true).

    updateMissionState("inorbit_target").
}

IF mission_state = "changed_ap" {
}