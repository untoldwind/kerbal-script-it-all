// Fall back to the surface (hopefully with some means of breaking)

RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_parts").

function atmoDeorbitSimple {
    partsRetractAntennas().

	SAS off.
	LOCK STEERING TO SHIP:RETROGRADE.

	WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

	LOCK THROTTLE TO 1.

	UNTIL SHIP:ALTITUDE < 70000 or SHIP:ORBIT:PERIAPSIS < 0 {
		stagingCheck().
		wait 0.5.
	}

	UNLOCK all.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

	SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".
}
