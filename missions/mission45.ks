RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/rendezvous/dock").
RUNONCEPATH("/rendezvous/depart").
RUNONCEPATH("/atmo/deorbit_simple").
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
    SET TARGET TO Mun.
    mainframeHohmann().

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
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    UNTIL STAGE:NUMBER = 1 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    SET TARGET TO "Arrey's Craft".
    mainframeHohmann().

    updateMissionState("intransit_arrey").
}

IF mission_state = "intransit_arrey" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_arrey").
}

IF mission_state = "neartarget_arrey" {
    rendezvousApproach().

    updateMissionState("attarget_arrey").
} ELSE IF mission_state = "attarget_arrey" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_mun2").
}

IF mission_state = "inorbit_mun2" {
    SET TARGET TO "Lizke's Debris".
    mainframeHohmann().

    updateMissionState("intransit_lizke").
}

IF mission_state = "intransit_lizke" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_lizke").
}

IF mission_state = "neartarget_lizke" {
    rendezvousApproach().

    updateMissionState("attarget_lizke").
} ELSE IF mission_state = "attarget_lizke" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_mun3").
}

IF mission_state = "inorbit_mun3" {
    SET TARGET TO "Mun Station 1".

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

IF mission_state = "attarget_station" {
    rendezvousDock().

    updateMissionState("docked").
} ELSE IF mission_state = "docked" {
    rendezvousDepart().

    updateMissionState("undocked").
}

IF mission_state = "undocked" {
    mainframeReturnFromMoon(180000).

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    mainframeTransfer().

    mainframeChangePeriapsis(90000).

	SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".

    warpSeconds(ETA:PERIAPSIS - 120).

    SET THROTTLE TO 1.

    LIST ENGINES IN remaining_engines.

    WAIT UNTIL remaining_engines[0]:FLAMEOUT.

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    partsRetractAntennas().
    partsRetractSolarPanels().
    updateMissionState("done").
}