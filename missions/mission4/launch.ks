
LOCK STEERING TO UP.

SAS on.

LIST ENGINES in all_engines.

LOCAL main_engine IS all_engines[0].

SET PID TO PIDLOOP(0.01, 0.006, 0.006).
SET PID:SETPOINT TO 200.

SET thrott TO 1.
LOCK THROTTLE TO thrott.

LOCAL command_pod IS SHIP:CREW[0]:PART.
LOCAL barometers IS SHIP:PARTSNAMED("sensorBarometer").

PRINT "Ground experiments".

LOCAL experiment IS barometers[0]:GETMODULE("ModuleScienceExperiment").

experiment:DEPLOY.
wait until experiment:HASDATA.

PRINT "Launch".

STAGE.

WAIT UNTIL SHIP:VERTICALSPEED > 120.

UNTIL main_engine:FLAMEOUT {
    SET thrott TO thrott + PID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
    if thrott > 1 {
        SET thrott TO 1.
    }
    if thrott < 0 {
        SET thrott TO 0.
    }
    WAIT 0.001.
}

wait until SHIP:VERTICALSPEED < 0.

barometers[1]:GETMODULE("ModuleScienceExperiment"):DEPLOY.

UNLOCK STEERING.
UNLOCK THROTTLE.

SAS off.

STAGE.

PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
