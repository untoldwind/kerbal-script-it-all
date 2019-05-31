RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/vac2/lib").

mainframeEnsure().

IF mission_state = "launch" {
    SET TARGET TO Ike.
    mainframeHohmann().

    updateMissionState("intransit_ike").
}

IF mission_state = "intransit_ike" {
    mainframeTransfer().

    updateMissionState("entered_munsoi").
}

IF mission_state = "entered_munsoi" {
    mainframeChangePeriapsis(60000).
    mainframeCircularize().

    updateMissionState("inorbit_ike").
}

IF mission_state = "inorbit_ike" {
    LOCAL LandSite IS WAYPOINT("Ike Landing"):GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG).

    updateMissionState("landed").
} ELSE IF mission_state = "landed" {
    vacLaunchAscent(30000, 90).
    mainframeCircularize().

    updateMissionState("return_orbit").
}

IF mission_state = "return_orbit" {
    mainframeReturnFromMoon(200000).

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    mainframeTransfer().

    mainframeChangePeriapsis(200000).
    mainframeChangeApoapsis(200000, TIME + ETA:PERIAPSIS).

    updateMissionState("in_orbit_back").
}

IF mission_state = "in_orbit_back" {
    SET TARGET TO "Kerbol 1".
    
    mainframeBiImplusive().
    mainframeMatchVelocities().
  
    updateMissionState("at_mothership").
} ELSE IF mission_state = "at_mothership" {
    mainframeChangePeriapsis(90000).
    mainframeChangeApoapsis(90000, TIME + ETA:PERIAPSIS).

    updateMissionState("low_orbit_home").
} ELSE IF mission_state = "low_orbit_home" {
    SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".

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