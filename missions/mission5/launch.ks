RUNONCEPATH("/bare/lib_warp").
RUNONCEPATH("/bare/lib_staging").

PRINT "Launch sequence".
RUNPATH("/bare/launch_ascent").

PRINT "Launch sequence done. Begin circulating".
RUNPATH("/bare/circ").

PRINT "Reached orbit. Conduct experiments.".

FOR experiment in SHIP:MODULESNAMED("ModuleScienceExperiment") {
    experiment:DEPLOY.
}

WAIT 5.

PRINT "Enjoy view for a bit".

warpSeconds(900).

LOCK STEERING TO SHIP:RETROGRADE.

WAIT 5.

LOCK THROTTLE TO 1.

UNTIL SHIP:ALTITUDE < 75000 {
 	stagingCheck().
	wait 0.5.
}

UNLOCK all.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

STAGE.

PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.

updateMissionState("done").
