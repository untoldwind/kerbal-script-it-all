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

    mainframeChangePeriapsis(600000, TIME + 240).
    mainframeCircularize().

    updateMissionState("in_orbit_duna").
} ELSE IF mission_state = "in_orbit_duna" {
    SET TARGET to Kerbin.
    mainframeInterplanetaryBiImpulsive(false, 2 * 7200000).

    updateMissionState("planed_return").
} ELSE IF mission_state = "planed_return" {
    mainframeExecNode().

    updateMissionState("exit_back").
} ELSE IF mission_state = "exit_back" {
    mainframeCorrectTargetPeriapsis(200000, false).

    updateMissionState("in_transit_back").
} ELSE IF mission_state = "in_transit_back" {
    mainframeExecNode().

    updateMissionState("corrected_back").
} ELSE IF mission_state = "corrected_back" {
    mainframeTransfer().

    mainframeChangePeriapsis(200000).
    mainframeCircularize().

    updateMissionState("back_at_kerbin").
} ELSE IF mission_state = "back_at_kerbin" {
    SET TARGET TO Minmus.
    mainframeBiImplusive().

    updateMissionState("intransit_mun").
}

IF mission_state = "intransit_mun" {
    mainframeCorrectTargetPeriapsis(100000).

    updateMissionState("corrected_transit_mun").
}

IF mission_state = "corrected_transit_mun" {
    mainframeTransfer().

    updateMissionState("entered_munsoi").
}

IF mission_state = "entered_munsoi" {
    mainframeChangePeriapsis(70000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    SET TARGET TO "Minmus Station 1".

    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_station_mun").
}

IF mission_state = "intransit_station_mun" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_station_mun").
}
