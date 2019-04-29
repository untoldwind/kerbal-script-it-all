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
}