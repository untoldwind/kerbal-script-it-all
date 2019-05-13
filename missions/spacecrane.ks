RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/vac2/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/rendezvous/lib").


SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "landed" {
    LIGHTS ON.
    local DPort is dockChooseDeparturePort().

    local TargetUndock is core:vessel.

    if DPort <> 0 {
        DPort:Undock(). 
        wait 0.1.
    }

    PRINT "Launch sequence".
    vacLaunchAscent(60000).
    mainframeCircularize().

    updateMissionState("inorbit_mun2").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Mission 93 Base".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_target").
}

IF mission_state = "at_target" {
    rendezvousDock().

    updateMissionState("docked").
} ELSE IF mission_state = "docked" {
    SET TARGET TO Mun.

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
    mainframeChangePeriapsis(100000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    LOCAL LandSite IS WAYPOINT("Minmus Landing"):GEOPOSITION.
//    SET TARGET TO "Mun Landing".
//    LOCAL LandSite IS TARGET:GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG, true, -1, true).

    updateMissionState("landed").
}

IF mission_state = "inorbit_mun2" {
    SET TARGET TO "Mun Station 1".

    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().

    updateMissionState("at_station").
}

IF mission_state = "at_station" {
    rendezvousDock().

    updateMissionState("docked_station").
} ELSE IF mission_state = "docked_station" {
    rendezvousDepart(0, -1).

    updateMissionState("undocked").
}

IF mission_state = "undocked" {
    mainframeReturnFromMoon(180000).

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    mainframeTransfer().
    mainframeChangePeriapsis(150000).
    mainframeChangeApoapsis(150000, TIME + ETA:PERIAPSIS).

    updateMissionState("inorbit").

}