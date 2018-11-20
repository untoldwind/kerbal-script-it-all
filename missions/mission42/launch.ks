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

    SET TARGET TO "Haibin's Heap".
    mainframeHohmann().

    updateMissionState("intransit_halbin").
}

IF mission_state = "intransit_halbin" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_halbin").
}

IF mission_state = "neartarget_halbin" {
    rendezvousApproach().

    updateMissionState("attarget_halbin").
} ELSE IF mission_state = "attarget_halbin" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_mun2").
}

IF mission_state = "inorbit_mun2" {
    SET TARGET TO "Sieul's Derelict".
    mainframeHohmann().

    updateMissionState("intransit_sieul").
}

IF mission_state = "intransit_sieul" {
    mainframeMatchVelocities().

    updateMissionState("neartarget_sieul").
}

IF mission_state = "neartarget_sieul" {
    rendezvousApproach().

    updateMissionState("attarget_sieul").
} ELSE IF mission_state = "attarget_sieul" {
    mainframeChangeApoapsis(50000).

    mainframeCircularize().

    updateMissionState("inorbit_mun3").
}

IF mission_state = "inorbit_mun3" {
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