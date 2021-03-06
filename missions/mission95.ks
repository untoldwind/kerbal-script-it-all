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
    mainframeReturnFromMoon(60000000).

    updateMissionState("transfer_to_kerbin").
}

IF mission_state = "transfer_to_kerbin" {
    mainframeTransfer().

    mainframeChangeApoapsis(60000000, TIME + ETA:PERIAPSIS, False).

    updateMissionState("kerbin_high_orbit_prep").
} ELSE IF mission_state = "kerbin_high_orbit_prep" {
    mainframeExecNode().

    mainframeChangePeriapsis(60000000, TIME + ETA:APOAPSIS, False).
    updateMissionState("kerbin_high_orbit").
} ELSE IF mission_state = "kerbin_high_orbit" {
    mainframeExecNode().

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
