RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/rendezvous/dock").
RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_warp").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).
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
    mainframeChangePeriapsis(70000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    SET TARGET TO "Minmus Station 1".

    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_station").
}

IF mission_state = "intransit_station" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_station").
}

IF mission_state = "neartarget_station" {
    rendezvousApproach().

    updateMissionState("attarget_station").
}

IF mission_state = "docked" {
    rendezvousDock().

    updateMissionState("docked").
} 
