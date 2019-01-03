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
    SET TARGET TO "Jerbart's Wreckage".

    mainframeBiImplusive().

    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target1").
} ELSE IF mission_state = "at_target1" {
    mainframeChangeApoapsis(150000, TIME + 240).
    mainframeCircularize().

    updateMissionState("inorbit2").
}

IF mission_state = "inorbit2" {
    SET TARGET TO "Keldun's Derelict".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target3").
} ELSE IF mission_state = "at_target3" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
