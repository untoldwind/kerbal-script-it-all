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
    SET TARGET to Duna.
    mainframeInterplanetaryBiImpulsive(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
}