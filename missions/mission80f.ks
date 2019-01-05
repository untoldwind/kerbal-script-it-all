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
    SET TARGET TO "Kerbol 1".

    mainframeBiImplusive().
    mainframeCorrectTarget().
    mainframeMatchVelocities().

    updateMissionState("intransit_mun").
}

IF mission_state = "intransit_mun" {
    rendezvousApproach().
    rendezvousDock().
    updateMissionState("docked").
} ELSE IF mission_state = "docked" {
    rendezvousDepart().

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
