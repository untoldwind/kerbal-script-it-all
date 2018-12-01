RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
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

    updateMissionState("intransit_minmus").
}

IF mission_state = "intransit_minmus" {
    mainframeCorrectTargetPeriapsis(100000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_minmussoi").
    updateMissionState("entered_minmussoi").
}

IF mission_state = "entered_minmussoi" {
    mainframeChangePeriapsis(30000).
    mainframeCircularize().

    updateMissionState("inorbit_minmus").
}

IF mission_state = "inorbit_minmus" {
    UNTIL STAGE:NUMBER = 1 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    SET TARGET TO "Jebgel's Hulk".
    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_resc1").
}

IF mission_state = "intransit_resc1" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_resc1").
}

IF mission_state = "neartarget_resc1" {
    rendezvousApproach().

    updateMissionState("attarget_resc1").
} ELSE IF mission_state = "attarget_resc1" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_minmus2").
}

IF mission_state = "inorbit_minmus2" {
    SET TARGET TO "Steldan's Wreckage".
    mainframeMatchPlanes().
    mainframeHohmann().

    updateMissionState("intransit_resc2").
}

IF mission_state = "intransit_resc2" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_resc2").
}

IF mission_state = "neartarget_resc2" {
    rendezvousApproach().

    updateMissionState("attarget_resc2").
} ELSE IF mission_state = "attarget_resc2" {
    SET TARGET TO "Maubles' Wreckage".
    mainframeBiImplusive().

    updateMissionState("intransit_resc3").
} 

IF mission_state = "intransit_resc3" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_resc3").
}

IF mission_state = "neartarget_resc3" {
    rendezvousApproach().

    updateMissionState("attarget_resc3").
} ELSE IF mission_state = "attarget_resc3" {
    mainframeCircularize().
    mainframeReturnFromMoon(180000).

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    mainframeTransfer().

    mainframeChangePeriapsis(75000).

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