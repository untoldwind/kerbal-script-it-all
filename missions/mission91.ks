RUNONCEPATH("/mainframe/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    mainframeReturnFromMoon(30000000).

    updateMissionState("transfer_out").
}

IF mission_state = "transfer_out" {
    mainframeTransfer().
    mainframeChangePeriapsis(35000000).
    mainframeChangeApoapsis(35000000, TIME + ETA:PERIAPSIS).

    updateMissionState("hi_orbit").
}

IF mission_state = "hi_orbit" {
    SET TARGET to Dres.
    mainframeInterplanetaryBiImpulsive(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
} ELSE IF mission_state = "leaving_soi" {
    mainframeTransfer().

    updateMissionState("soi_exit").
} ELSE IF mission_state = "soi_exit" {
    mainframeCorrectTargetPeriapsis(20000, false).

    updateMissionState("correction_planed").
} ELSE IF mission_state = "correction_planed" {
    mainframeExecNode().

    updateMissionState("in_transit").
} ELSE IF mission_state = "in_transit" {
    mainframeTransfer().

    mainframeChangePeriapsis(20000).
    mainframeCircularize().

    updateMissionState("in_orbit_duna").
}
