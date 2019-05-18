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
    SET TARGET to Jool.
    mainframeInterplanetaryBiImpulsive(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
} ELSE IF mission_state = "leaving_soi" {
    mainframeTransfer().

    updateMissionState("soi_exit").
} ELSE IF mission_state = "soi_exit" {
    mainframeCorrectTargetPeriapsis(80000000, false).

    updateMissionState("correction_planed").
} ELSE IF mission_state = "correction_planed" {
    mainframeExecNode().

    updateMissionState("in_transit").
} ELSE IF mission_state = "in_transit" {
    mainframeTransfer().

    updateMissionState("transfered").
} ELSE IF mission_state = "transfered" {
    mainframeChangePeriapsis(80000000).

    updateMissionState("corrected").
} ELSE IF mission_state = "corrected" {
    mainframeCircularize().

    updateMissionState("in_orbit_jool").
} ELSE IF mission_state = "in_orbit_jool" {
    SET target to Vall.

    mainframeBiImplusive().

    updateMissionState("intransit_vall").
}

IF mission_state = "intransit_vall" {
    mainframeCorrectTargetPeriapsis(150000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_vallsoi").
}

IF mission_state = "entered_vallsoi" {
    mainframeCircularizeIn(ETA:PERIAPSIS).

    updateMissionState("inorbit_vall").
}


