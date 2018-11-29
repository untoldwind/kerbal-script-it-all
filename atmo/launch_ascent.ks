// Perform a standard ascent launch (i.e. a rocket, spaceplanes need their own thing)
//
// Parameters:
//   Target apoapsis (in m, default: 90000)
//   Launch heading (degree, default: 90)


RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/core/lib_parts").

function atmoLaunchAscent {
	parameter targetApoapsis is 90000.
	parameter launchHeading is 90.
	// Starting/ending height of gravity turn
	GLOBAL launch_gt0 is BODY:ATM:HEIGHT * 0.007.
	GLOBAL launch_gt1 is BODY:ATM:HEIGHT * 0.6. 

	// Steering function for continuous lock.
	function ascentSteering {
		// How far through our gravity turn are we? (0..1)
		LOCAL gtPct is MIN(1, MAX(0, (SHIP:ALTITUDE - launch_gt0) / (launch_gt1 - launch_gt0))).
		// Ideal gravity-turn azimuth (inclination) and facing at present altitude.
		LOCAL pitch is ARCCOS(gtPct).

		return heading(launchHeading, pitch).
	}

	// Throttle function for continuous lock.
	function ascentThrottle {
		// angle of attack
		LOCAL aoa is SHIP:FACING:VECTOR * SHIP:VELOCITY:SURFACE.
		// how far through the soup are we?
		LOCAL atmPct is SHIP:ALTITUDE / (BODY:ATM:HEIGHT + 1).
		LOCAL spd is SHIP:AIRSPEED.

		LOCAL cutoff is 200 + (400 * MAX(0, (atmPct*3))).

		if spd > cutoff {
			// going too fast - avoid overheat or aerodynamic catastrophe
			// by limiting throttle but not less than 10% to keep some gimbaling
			return 1 - MAX(0.1, ((spd - cutoff) / cutoff)).
		} else {
			// Ease throttle when near the Apoapsis
			LOCAL apoPercent is SHIP:ORBIT:APOAPSIS / targetApoapsis.
			LOCAL apoCompensation is 0.
			if apoPercent > 0.9 set apoCompensation to (apoPercent - 0.9) * 10.
			return 1.05 - MIN(1, MAX(0, apoCompensation)).
		}
	}

	PRINT "Launch: Target Apoapsis: " + targetApoapsis + " Heading: " + launchHeading.

	STAGE.

	LOCK STEERING TO ascentSteering().
	LOCK THROTTLE TO ascentThrottle().

	UNTIL SHIP:ORBIT:APOAPSIS >= targetApoapsis {
		stagingCheck().
		wait 0.001.
	}

	UNLOCK THROTTLE.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

	LOCK STEERING TO SHIP:PROGRADE.

	WAIT UNTIL SHIP:ALTITUDE > BODY:ATM:HEIGHT * 0.9.

	UNLOCK ALL.

	partsDeployFairings().
	partsExtendAntennas().
	partsExtendSolarPanels().
}
