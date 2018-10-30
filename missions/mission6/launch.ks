LOCK STEERING TO UP.
LOCK THROTTLE TO 1.

SAS on.

LIST ENGINES in all_engines.

LOCAL main_engine IS all_engines[0].

LOCAL command_pod IS SHIP:CREW[0]:PART.
PRINT "Launch".

STAGE.

wait until main_engine:FLAMEOUT.

PRINT "Flameout".

wait until SHIP:VERTICALSPEED < 0.

PRINT "Drop engine".

SAS off.

STAGE.

PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
