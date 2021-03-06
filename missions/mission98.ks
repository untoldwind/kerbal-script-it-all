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

IF mission_state = "in_orbit_minmus" {
    mainframeReturnFromMoon(90000).

    updateMissionState("transfer_to_kerbin").
}

IF mission_state = "transfer_to_kerbin" {
    mainframeTransfer().

    mainframeChangePeriapsis(90000, TIME + ETA:APOAPSIS, False).

    updateMissionState("kerbin_low_orbit_prep").
} ELSE IF mission_state = "kerbin_low_orbit_prep" {
    mainframeExecNode().

    mainframeChangeApoapsis(90000, TIME + ETA:PERIAPSIS, False).

    updateMissionState("kerbin_low_orbit").
} ELSE IF mission_state = "kerbin_low_orbit" {
    SET TARGET to Duna.
    mainframeInterplanetaryBiImpulsive(false).

    updateMissionState("planed").
} ELSE IF mission_state = "planed" {
    mainframeExecNode().

    updateMissionState("leaving_soi").
} ELSE IF mission_state = "leaving_soi" {
//    mainframeTransfer().

    updateMissionState("soi_exit").
} ELSE IF mission_state = "soi_exit" {
    mainframeCorrectTargetPeriapsis(200000, false).

    updateMissionState("correction_planed").
} ELSE IF mission_state = "correction_planed" {
    mainframeExecNode().

    updateMissionState("in_transit").
} ELSE IF mission_state = "in_transit" {
    mainframeTransfer().

    mainframeChangePeriapsis(200000).
    mainframeCircularize().

    updateMissionState("in_orbit_dres").
} ELSE IF mission_state = "in_orbit_dres" {
    mainframeChangePeriapsis(90000, TIME + ETA:APOAPSIS).
    mainframeChangeApoapsis(90000, TIME + ETA:PERIAPSIS).

    updateMissionState("in_orbit_duna_low").
} ELSE IF mission_state = "in_orbit_duna_low" {
    LOCAL LandSite IS WAYPOINT("Duna Landing"):GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG, true, 1).

    updateMissionState("landed").
}
