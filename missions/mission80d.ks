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
    mainframeCorrectTargetPeriapsis(100000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_munsoi").
}

IF mission_state = "entered_munsoi" {
    mainframeChangePeriapsis(60000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    SET TARGET TO "Minmus Station 1".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().
    rendezvousDock().

    updateMissionState("docked").
} ELSE IF mission_state = "docked" {
    rendezvousDepart().

    SET TARGET TO "Jedney's Wreckage".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target1").
} ELSE IF mission_state = "at_target1" {
    mainframeChangeApoapsis(60000).
    mainframeCircularize().

    updateMissionState("inorbit_mun1").
}

IF mission_state = "inorbit_mun1" {
    SET TARGET TO "Leakin's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target2").
} ELSE IF mission_state = "at_target2" {
    mainframeChangeApoapsis(60000).
    mainframeCircularize().

    updateMissionState("inorbit_mun2").
}

IF mission_state = "inorbit_mun2" {
    SET TARGET TO "Seeus' Wreckage".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target3").
} ELSE IF mission_state = "at_target3" {
    SET TARGET TO "Milner's Shipwreck".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target4").
} ELSE IF mission_state = "at_target4" {
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
