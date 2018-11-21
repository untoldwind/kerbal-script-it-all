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
    SET TARGET TO Minmus.
    mainframeHohmann().

    updateMissionState("intransit_minmus").
}

IF mission_state = "intransit_minmus" {
    mainframeCorrectTargetPeriapsis(-200000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_minmussoi").
}

IF mission_state = "entered_minmussoi" {
    mainframeCircularize().

    updateMissionState("inorbit_minmus").
}

IF mission_state = "inorbit_minmus" {
    UNTIL STAGE:NUMBER = 1 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    SET TARGET TO "Mission 43".
    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_other").
}

IF mission_state = "intransit_other" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_other").
}

IF mission_state = "neartarget_other" {
    rendezvousApproach().

    updateMissionState("attarget_other").
}

IF mission_state = "attarget_other" {
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