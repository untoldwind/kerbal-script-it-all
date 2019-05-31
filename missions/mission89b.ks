RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/vac2/lib").

mainframeEnsure().

IF mission_state = "launch" {
    mainframeChangePeriapsis(120000).
    mainframeChangeApoapsis(120000, TIME + ETA:PERIAPSIS).

    updateMissionState("low_orbit").
}

IF mission_state = "low_orbit" {
    LOCAL LandSite IS WAYPOINT("Duna Landing"):GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG).

    updateMissionState("landed").
} ELSE IF mission_state = "landed" {
    vacLaunchAscent(120000, 90).
    mainframeCircularize().

    updateMissionState("return_orbit").
}

IF mission_state = "return_orbit" {
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