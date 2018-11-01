// Fall back to the surface (hopefully with some means of breaking)

RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/core/lib_util").

LOCK STEERING TO SHIP:RETROGRADE.

WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

LOCK THROTTLE TO 1.

UNTIL SHIP:ALTITUDE < 75000 {
 	stagingCheck().
	wait 0.5.
}

UNLOCK all.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

STAGE.

