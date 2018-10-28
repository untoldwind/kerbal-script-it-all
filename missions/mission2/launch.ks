LOCK STEERING TO UP.
LOCK THROTTLE TO 1.

SAS on.

LIST ENGINES in all_engines.

LOCAL liquid_engine IS all_engines[0].
LOCAL booster_engine IS all_engines[1].

LOCAL command_pod IS SHIP:CREW[0]:PART.
LOCAL mystery_goo IS SHIP:PARTSNAMED("GooExperiment")[0].
LOCAL thermometer IS SHIP:PARTSNAMED("sensorThermometer")[0].

PRINT "Launch".

STAGE.

wait until booster_engine:FLAMEOUT.

PRINT "Flameout Booster".

// Contract demands this
wait until SHIP:VERTICALSPEED < 580.

STAGE.

wait until liquid_engine:FLAMEOUT.

PRINT "Flameout liquid engine".

UNLOCK STEERING.
UNLOCK THROTTLE.

SAS off.

wait until SHIP:VERTICALSPEED < 50.

PRINT "In-flight experiments".

mystery_goo:GETMODULE("ModuleScienceExperiment"):DEPLOY.
thermometer:GETMODULE("ModuleScienceExperiment"):DEPLOY.
command_pod:GETMODULE("ModuleScienceExperiment"):DEPLOY.


STAGE.

PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
