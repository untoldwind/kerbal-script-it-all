RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/plane/lib").
RUNONCEPATH("/rendezvous/lib").

mainframeEnsure().

IF mission_state = "launch" {
    planeLaunchSSTO(150000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Chadlin's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target").
} ELSE IF mission_state = "at_target" {
    mainframeChangePeriapsis(80000, TIME + 240).
    mainframeChangeApoapsis(80000, TIME + ETA:periapsis).

    updateMissionState("orbit_down").
}

IF mission_state = "orbit_down" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
