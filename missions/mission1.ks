LOCK STEERING TO UP.
LOCK THROTTLE TO 1.

SAS on.

LIST ENGINES in all_engines.

LOCAL main_engine IS all_engines[0].

LOCAL command_pod IS SHIP:CREW[0]:PART.
LOCAL mystery_goos IS SHIP:PARTSNAMED("GooExperiment").

PRINT "Ground experiment: Goo".

LOCAL experiment IS mystery_goos[0]:GETMODULE("ModuleScienceExperiment").

experiment:DEPLOY.
wait until experiment:HASDATA.

PRINT "Launch".

STAGE.

wait until main_engine:FLAMEOUT.

PRINT "Flameout".

PRINT "In-flight experiment: Goo".

SET experiment TO mystery_goos[1]:GETMODULE("ModuleScienceExperiment").

experiment:DEPLOY.
wait until experiment:HASDATA.

PRINT "In-flight experiment: Crew Report".

SET experiment TO command_pod:GETMODULE("ModuleScienceExperiment").

experiment:DEPLOY.
wait until experiment:HASDATA.

wait until SHIP:VERTICALSPEED < 0.

PRINT "Drop engine".

SAS off.

STAGE.

PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.

updateMissionState("done").
