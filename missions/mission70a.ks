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
    SET TARGET TO "Johnger's Shipwreck".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target1").
} ELSE IF mission_state = "at_target1" {
    SET TARGET TO "Kathpont's Wreckage".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target2").
} ELSE IF mission_state = "at_target2" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
