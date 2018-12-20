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
    SET TARGET TO "Deshat's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target1").
} ELSE IF mission_state = "at_target1" {
    mainframeChangeApoapsis(150000).
    mainframeCircularize().

    updateMissionState("inorbit2").
}

IF mission_state = "inorbit2" {
    SET TARGET TO "Johndard's Pod".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target2").
} ELSE IF mission_state = "at_target2" {
    mainframeChangeApoapsis(150000).
    mainframeCircularize().

    updateMissionState("inorbit3").
}

IF mission_state = "inorbit3" {
    SET TARGET TO "Nawise's Wreckage".

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
