RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
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
    mainframeCorrectTargetPeriapsis(100000).

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

    SET TARGET TO "Andard's Hulk".
    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_andard").
}

IF mission_state = "intransit_andard" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_andard").
}

IF mission_state = "neartarget_andard" {
    rendezvousApproach().

    updateMissionState("attarget_andard").
} ELSE IF mission_state = "attarget_andard" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_minmus2").
}

IF mission_state = "inorbit_minmus2" {
    SET TARGET TO "Valfred's Shipwreck".
    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_valfred").
}

IF mission_state = "intransit_valfred" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_valfrad").
}

IF mission_state = "neartarget_valfrad" {
    rendezvousApproach().

    updateMissionState("attarget_valfred").
} ELSE IF mission_state = "attarget_valfred" {
    mainframeCircularize().

    updateMissionState("inorbit_minmus3").
} ELSE IF mission_state = "inorbit_minmus3" {
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