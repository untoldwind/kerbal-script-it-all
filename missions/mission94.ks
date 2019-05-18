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
    SET TARGET TO "Merfry's Derelict".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target").
} ELSE IF mission_state = "at_target" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
