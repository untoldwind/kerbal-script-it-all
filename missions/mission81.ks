RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/rendezvous/dock").

IF mission_state = "launch" {
    vacLaunchAscent(30000, 90).
    mainframeCircularize().

    updateMissionState("in_orbit").
}

IF mission_state = "in_orbit" {
    SET TARGET TO "Minmus Station 1".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target").
}

IF mission_state = "at_target" {
    rendezvousDock().

    updateMissionState("done").
}
