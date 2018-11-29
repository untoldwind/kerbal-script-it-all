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
    SET TARGET TO Mun.
    mainframeBiImplusive().

    updateMissionState("intransit_minmus").
}

IF mission_state = "intransit_minmus" {
    mainframeCorrectTargetPeriapsis(120000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_soi").
}

IF mission_state = "entered_soi" {
    mainframeChangePeriapsis(120000).
    mainframeCircularize().

    updateMissionState("inorbit_target").
}

IF mission_state = "inorbit_target" {
    mainframeChangeInclination(90).

    updateMissionState("done").
}