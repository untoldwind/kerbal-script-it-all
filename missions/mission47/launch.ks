RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO Minmus.
    mainframeHohmann().

    updateMissionState("intransit_minmus").
}

IF mission_state = "intransit_minmus" {
    mainframeCorrectTargetPeriapsis(50000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_soi").
}

IF mission_state = "entered_soi" {
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("done").
}