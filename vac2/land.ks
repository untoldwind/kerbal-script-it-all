RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib_land").
RUNONCEPATH("/mainframe/exec_node").


function vacLand {
    parameter LandLat is 0.
    parameter LandLng is 0.
    parameter breakZero is true.
    parameter landingStage is -1.

    uiConsole("VACLAND", "Start").
    clearvecdraws().

    LOCAL LandingSite is LATLNG(LandLat,LandLng).

    addons:mainframe:landing:prediction_start(LandingSite).

    if ship:status = "ORBITING" {
        vacLandPrepareDeorbit(LandingSite).

        if landingStage >= 0 {
            UNTIL STAGE:NUMBER = landingStage {
                WAIT UNTIL STAGE:READY.
                STAGE.
            }
        }
    }

    if ship:status = "SUB_ORBITAL" OR ship:status = "FLYING" {
        UNTIL addons:mainframe:landing:PREDICTED_OUTCOME = "LANDED" {
            wait 0.
        }

        if addons:mainframe:landing:predicted_break_time > TIME + 10 and landRadarAltimeter() > 500 {
            vacCourseCorrection(LandingSite).
        }

        if landRadarAltimeter() > 500 {
            vacDecelerationBurn().
        }
        if breakZero {
            vacBreakZero().
        }
        vacTouchdown().
    }

    addons:mainframe:landing:prediction_stop().
}

function vacLandPrepareDeorbit {
    parameter LandingSite.

    uiConsole("VACLAND", "Prepare Deorbit").

    LOCAL DeorbitRad is ship:body:radius - 3000.

    LOCAL r1 is ship:orbit:semimajoraxis.                               //Orbit now
    LOCAL r2 is DeorbitRad .                                            // Target orbit
    LOCAL pt is 0.5 * ((r1+r2) / (2*r2))^1.5.                           // How many orbits of a target in the target (deorbit) orbit will do.
    LOCAL sp is SQRT( ( 4 * constant:pi^2 * r2^3 ) / body:mu ).         // Period of the target orbit.
    LOCAL DeorbitTravelTime is pt*sp /2.                                // Transit time 
    LOCAL phi is (DeorbitTravelTime/ship:body:rotationperiod) * 360.    // Phi in this case is not the angle between two orbits, but the angle the body rotates during the transit time
    LOCAL IncTravelTime is SHIP:ORBIT:period / 2. // Travel time between change of inclinationa and lower perigee
    LOCAL phiIncManeuver is (IncTravelTime/ship:body:rotationperiod) * 360.

    // Deorbit and plane change longitudes
    LOCAL Deorbit_Long to utilAngleTo360(LandingSite:LNG - 90).
    LOCAl PlaneChangeLong to utilAngleTo360(LandingSite:LNG - 270).

    IF SHIP:ORBIT:INCLINATION < -90 OR SHIP:ORBIT:INCLINATION > 90 {
        SET Deorbit_Long to utilAngleTo360(LandingSite:LNG + 90).
        SET PlaneChangeLong to utilAngleTo360(LandingSite:LNG + 270).
    }

    // Plane change for landing site
    LOCAL vel is velocityat(ship, landTimeToLong(PlaneChangeLong)):orbit.
    LOCAL inc is LandingSite:lat.
    LOCAL nDv is vel:mag * sin(inc).
    LOCAL pDV is vel:mag * (cos(inc) - 1 ).

    if nDv * nDv + pDv * pDv > 0.1 { // Only burn if it matters.
        uiDebug("Deorbit: Burning dV of " + round(SQRT(nDv * nDv + pDv * pDv),1) + " m/s @ anti-normal to change plane.").
        utilRemoveNodes().
        LOCAL nd IS NODE(time:seconds + landTimeToLong(PlaneChangeLong+phiIncManeuver), 0, -nDv, pDv).
        add nd.
        WAIT 1. 
        mainframeExecNode().
    }

    // Lower orbit over landing site
    local Deorbit_dV is landDeorbitDeltaV(DeorbitRad-body:radius).
    uiDebug("Deorbit: Burning dV of " + round(Deorbit_dV,1) + " m/s retrograde to deorbit.").
    utilRemoveNodes().
    LOCAL nd IS NODE(time:seconds + landTimeToLong(Deorbit_Long+phi) , 0, 0, Deorbit_dV).
    add nd. 
    WAIT 1. 
    mainframeExecNode(). 
}

function vacCourseCorrection {
    parameter LandingSite.

    uiConsole("VACLAND", "Course Correction").

    LOCAL desiredSite TO LandingSite.
    LOCK predictedBreakTime TO addons:mainframe:landing:predicted_break_time.
    LOCK courseCorrection TO addons:mainframe:landing:COURSE_CORRECTION_DETLAV(true).
    LOCK predictedSite TO addons:mainframe:landing:predicted_site.

    function throttleControl {
        IF NOT utilIsShipFacing(courseCorrection:DIRECTION, 10, 1) {
            return 0.
        }
        return MIN(1, MAX(0.1, courseCorrection:mag * SHIP:MASS/MAX(1,SHIP:AVAILABLETHRUST))).

    }

    LOCK STEERING TO courseCorrection:DIRECTION.
    LOCK THROTTLE TO throttleControl.

    until predictedBreakTime < TIME + 20 OR (predictedSite:POSITION - desiredSite:POSITION):MAG < 500 {
        PRINT "Desired Site    : " + desiredSite + "                           " at (0,0).
        PRINT "Predicted Site  : " + predictedSite + "                           " at (0,1).
        PRINT "Couse correction: " + courseCorrection + "                           " at (0,2).
        PRINT "Dist            : " + (predictedSite:POSITION - desiredSite:POSITION):MAG + "                           " at (0,3).

        WAIT 0.1.
    }
    UNLOCK THROTTLE. UNLOCK STEERING.
}

function vacDecelerationBurn {
    uiConsole("VACLAND", "Deceleration Burn").

    LOCAL DrawDebugVectors is true.

    LOCAL ThrottlePID IS PIDLOOP(0.04,0.001,0.01). // Kp, Ki, Kd
    SET ThrottlePID:MAXOUTPUT TO 1.
    SET ThrottlePID:MINOUTPUT TO 0.
    SET ThrottlePID:SETPOINT TO 0. 

    LOCAL VELAT IS VELOCITYAT(SHIP, addons:mainframe:landing:predicted_break_time):ORBIT.
    LOCAL steerDir IS LOOKDIRUP(-VELAT, POSITIONAT(SHIP, addons:mainframe:landing:predicted_break_time) - BODY:POSITION).
    LOCK STEERING TO steerDir.
    LOCAL throttleVal is 0.
    LOCK THROTTLE to throttleVal.

    WAIT UNTIL utilIsShipFacing(steerDir, 5).

    if addons:mainframe:landing:predicted_break_time > TIME + 20 {
        warpSeconds(addons:mainframe:landing:predicted_break_time:SECONDS - TIME:SECONDS - 20).
        SET steerDir TO SHIP:RETROGRADE.
    }
    LEGS on.
    LIGHTS on.

    LOCK radarAlt TO landRadarAltimeter().

    UNTIL radarAlt < 500 {
        WAIT 0.3.

        LOCAL ShipVelocity IS SHIP:velocity:surface.
        LOCAL limitedMaxThrustAccel IS MAX(0.1, throttleVal) * SHIP:AVAILABLETHRUST / SHIP:MASS.
        LOCAL CourseCorrecton IS addons:mainframe:landing:COURSE_CORRECTION_DETLAV(false).
        LOCAL correctionAngle IS MIN(0.5, CourseCorrecton:MAG / (2.0 * limitedMaxThrustAccel)).
        LOCAL SteerVector IS (-ShipVelocity:NORMALIZED + correctionAngle * CourseCorrecton:NORMALIZED):NORMALIZED.
        LOCAL desiredSpeed IS addons:mainframe:landing:DESIRED_SPEED.

        SET steerDir TO SteerVector:DIRECTION.
        SET throttleVal TO ThrottlePID:UPDATE(TIME:seconds,(desiredSpeed - ShipVelocity:MAG)).

        if DrawDebugVectors {
            SET DRAWSV TO VECDRAW(v(0,0,0), 10 *SteerVector, red, "Steering", 1, true, 1).
            SET DRAWCC TO VECDRAW(v(0,0,0),CourseCorrecton, green, "CourseCorrection", 1, true, 1).

            PRINT "Vertical speed " + abs(Ship:VERTICALSPEED) + "                           " at (0,0).
            Print "Target Vspeed  " + desiredSpeed            + "                           " at (0,1).
            print "Throttle       " + throttleVal             + "                           " at (0,2).
            print "Ship Velocity  " + ShipVelocity:MAG        + "                           " at (0,3).
            print "Ship height    " + radarAlt                + "                           " at (0,4).
            print "                                                                         " at (0,5).
        }
    }

    UNLOCK THROTTLE. UNLOCK STEERING.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function vacBreakZero {
    uiConsole("VACLAND", "Break zero").
    local accel is SHIP:availablethrust / SHIP:mass.

    lock steerDir to lookdirup(-SHIP:velocity:surface:normalized, ship:facing:upvector).
    lock steering to steerDir.
    wait until utilIsShipFacing(steerDir:vector, 10, 1) or landRadarAltimeter() < 300.

    lock throttle to min(SHIP:velocity:surface:mag / accel, 1.0).
    wait until (SHIP:velocity:surface:mag < 2) or landRadarAltimeter() < 300.
    lock throttle to 0.

    UNLOCK THROTTLE. UNLOCK STEERING.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function vacTouchdown {
    parameter TouchdownSpeed is 2.

    uiConsole("VACLAND", "Touchdown").

    LOCAL DrawDebugVectors is true.
        
    LOCAL ThrottlePID IS PIDLOOP(0.04,0.001,0.01). // Kp, Ki, Kd
    SET ThrottlePID:MAXOUTPUT TO 1.
    SET ThrottlePID:MINOUTPUT TO 0.
    SET ThrottlePID:SETPOINT TO 0. 

    LOCAL steerDir IS SHIP:RETROGRADE.
    LOCK STEERING TO steerDir.
    LOCAL throttleVal is 0.
    LOCK THROTTLE to throttleVal.

    LOCK radarAlt TO landRadarAltimeter().

    // Main landing loop
    UNTIL SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" {
        WAIT 0.
        // Steer the rocket
        SET ShipVelocity TO SHIP:velocity:surface.
        SET ShipHVelocity to vxcl(SHIP:UP:VECTOR,ShipVelocity).

        SET SteerVector to -ShipVelocity - ShipHVelocity.
        if DrawDebugVectors {
            SET DRAWSV TO VECDRAW(v(0,0,0),SteerVector, red, "Steering", 1, true, 1).
            SET DRAWV TO VECDRAW(v(0,0,0),ShipVelocity, green, "Velocity", 1, true, 1).
            SET DRAWHV TO VECDRAW(v(0,0,0),ShipHVelocity, YELLOW, "Horizontal Velocity", 1, true, 1).
        }
            
        set steerDir TO SteerVector:Direction. 

        // Throttle the rocket
        set TargetVSpeed to MAX(TouchdownSpeed,sqrt(radarAlt) - 5).

        IF abs(SHIP:VERTICALSPEED) > TargetVSpeed {
            set throttleVal TO ThrottlePID:UPDATE(TIME:seconds,(SHIP:VERTICALSPEED + TargetVSpeed)).
        }
        ELSE
        {
            set throttleVal TO 0.
        }

        if DrawDebugVectors { // I know, isn't the debug vectors but helps

            PRINT "Vertical speed " + abs(Ship:VERTICALSPEED) + "                           " at (0,0).
            Print "Target Vspeed  " + TargetVSpeed            + "                           " at (0,1).
            print "Throttle       " + throttleVal             + "                           " at (0,2).
            print "Ship Velocity  " + ShipVelocity:MAG        + "                           " at (0,3).
            print "Ship height    " + radarAlt                + "                           " at (0,4).
            print "                                                                    " at (0,5).

        }
        wait 0.
    }

    UNLOCK THROTTLE. UNLOCK STEERING.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    clearvecdraws().
    LADDERS ON.
    SAS ON. // Helps to don't tumble after landing
}
