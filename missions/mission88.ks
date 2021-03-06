RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/vac2/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    SET TARGET to Duna.
    mainframeInterplanetaryBiImpulsive(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
} ELSE IF mission_state = "leaving_soi" {
    mainframeTransfer().

    updateMissionState("soi_exit").
} ELSE IF mission_state = "soi_exit" {
    mainframeCorrectTargetPeriapsis(600000, false).

    updateMissionState("correction_planed").
} ELSE IF mission_state = "correction_planed" {
    mainframeExecNode().

    updateMissionState("in_transit").
} ELSE IF mission_state = "in_transit" {
    mainframeTransfer().

    mainframeChangePeriapsis(600000).
    mainframeCircularize().

    updateMissionState("in_orbit_duna").
} ELSE IF mission_state = "in_orbit_duna" {
    SET TARGET TO Ike.

    mainframeBiImplusive().
    mainframeTransfer().
    mainframeChangePeriapsis(50000, TIME + 240).
    mainframeChangeApoapsis(50000, TIME + ETA:PERIAPSIS).

    updateMissionState("inorbit_ike").
} ELSE IF mission_state = "inorbit_ike" {
    LOCAL LandSite IS WAYPOINT("Ike Landing"):GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG, true, 1).

    updateMissionState("landed").
}
