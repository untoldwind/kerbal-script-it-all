RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/plane/lib").
RUNONCEPATH("/rendezvous/lib").

mainframeEnsure().

IF mission_state = "launch" {
    planeLaunchSSTO(90000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO Minmus.
    mainframeBiImplusive().

    updateMissionState("intransit_mun").
}

IF mission_state = "intransit_mun" {
    mainframeCorrectTargetPeriapsis(50000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_munsoi").
}

IF mission_state = "entered_munsoi" {
    mainframeChangePeriapsis(50000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    SET TARGET TO "Newin's Wreckage".
//    SET TARGET TO "Leecott's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target").
} ELSE IF mission_state = "at_target" {
    SET TARGET TO "Leecott's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target2").
} ELSE IF mission_state = "at_target2" {
    mainframeReturnFromMoon(180000).

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    mainframeTransfer().
    mainframeChangePeriapsis(85000).
    mainframeChangeApoapsis(85000, TIME + ETA:PERIAPSIS).

    updateMissionState("in_orbit_back").
}

IF mission_state = "in_orbit_back" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
