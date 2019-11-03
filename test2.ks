RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/rendezvous/dock").
RUNONCEPATH("/plane/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

//atmoLaunchAscent(100000).


//vacLaunchAscent(60000, 90).
//mainframeCircularize().
//mainframeReturnFromMoon(1800000).


//SET TARGET to Duna.
//mainframeInterplanetaryBiImpulsive(false).

//SET TARGET TO "Minmus Station 1".
//mainframeBiImplusive().
//mainframeMatchVelocities().

//rendezvousDock().

//planeDisarmsChutes().
//planeSwitchAtmo().

//mainframeChangeInclination(0, TIME + 240).
//mainframeChangePeriapsis(120000, TIME + 240).
//mainframeChangeApoapsis(120000, TIME + ETA:periapsis).

  SET TARGET TO "Mun Landing".
  LOCAL LandSite IS TARGET:GEOPOSITION.
  vacLand(LandSite:LAT, LandSite:LNG, true, -1, false).
