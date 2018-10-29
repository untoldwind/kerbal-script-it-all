RUNONCEPATH("/bare/lib_util").
RUNONCEPATH("/bare/lib_warp").
RUNONCEPATH("/bare/lib_staging").

IF APOAPSIS > 0 and ETA:APOAPSIS < ETA:PERIAPSIS {
    SAS off.

    LOCK STEERING TO SHIP:PROGRADE.

    WAIT UNTIL utilIsShipFacing(SHIP:PROGRADE:FOREVECTOR).

    warpSeconds(ETA:APOAPSIS - 30).

    LOCK STEERING TO SHIP:PROGRADE.

    WAIT UNTIL ETA:APOAPSIS <= 20.

	LOCAL function circSteering {
		IF ETA:APOAPSIS < ETA:PERIAPSIS {
		//	prevent raising apoapsis
			if ETA:APOAPSIS > 1 {
                return PROGRADE:VECTOR + r(0, MAX(-30, MIN(0, -ETA:APOAPSIS)),0).
            }
		//	go prograde in last second (above velocityAt often has problems with time=now)
			return PROGRADE.
		}
		// pitch up a bit when we passed apopapsis to compensate for potentionally low TWR as this is often used after launch script
		// note that ship's pitch is actually yaw in world perspective (pitch = normal, yaw = radial-out)
		return PROGRADE:VECTOR + r(0, MIN(30, MAX(0, ORBIT:PERIOD - ETA:APOAPSIS)),0).
	}

    LOCK STEERING TO circSteering().
    LOCK THROTTLE TO (SQRT(BODY:MU/(BODY:RADIUS + APOAPSIS)) - SHIP:velocity:orbit:mag)*ship:mass/MAX(1, SHIP:AVAILABLETHRUST).
	local maxHeight is SHIP:ORBIT:APOAPSIS*1.01+1000.
	until ORBIT:eccentricity < 0.0005	// circular
		or ETA:APOAPSIS > ORBIT:period/3 and ETA:APOAPSIS < ORBIT:PERIOD*2/3 // happens with good accuracy
		or ORBIT:APOAPSIS > maxHeight and periapsis > max(BODY:ATM:HEIGHT,1000)+1000 // something went wrong?
		or ORBIT:APOAPSIS > maxHeight*1.5+5000 // something went really really wrong
	{
    	stagingCheck().
		wait 0.5.
	}

    UNLOCK all.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
} ELSE {
    PRINT "FATAL: Either escape trajectory or closer to periapsis".
}
