RUNONCEPATH("/atmo/lib").
RUNONCEPATH("/mainframe/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    SET TARGET to Duna.
    mainframeInterplanetaryLambert(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
} ELSE IF mission_state = "leaving_soi" {
    mainframeTransfer().

    updateMissionState("soi_exit").
} ELSE IF mission_state = "soi_exit" {
    mainframeCorrectTargetPeriapsis(200000, false).

    updateMissionState("correction_planed").
} ELSE IF mission_state = "correction_planed" {
    mainframeExecNode().

    updateMissionState("in_transit").
} ELSE IF mission_state = "in_transit" {
    mainframeTransfer().

    mainframeChangePeriapsis(240000).
    mainframeCircularize().

    updateMissionState("in_orbit_duna").
} ELSE IF mission_state = "in_orbit_duna" {
    mainframeChangeInclination(90).

    updateMissionState("in_polar_duna").
} ELSE IF mission_state = "in_polar_duna" {
    SET TARGET to Ike.

    mainframeBiImplusive().

    updateMissionState("intransit_ike").
}

IF mission_state = "intransit_ike" {
    mainframeTransfer().
    mainframeChangePeriapsis(150000).
    mainframeCircularize().

    updateMissionState("in_orbit_ike").
}

IF mission_state = "in_orbit_ike" {
    mainframeChangeInclination(90).

    updateMissionState("in_polar_ike").
}
