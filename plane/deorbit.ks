RUNONCEPATH("/mainframe/lib").

FUNCTION planeTimeToLong {
    PARAMETER lng.

    LOCAL SDAY IS SHIP:BODY:ROTATIONPERIOD. // Duration of Body day in seconds
    LOCAL KAngS IS 360/SDAY. // Rotation angular speed.
    LOCAL P IS SHIP:ORBIT:PERIOD.
    LOCAL SAngS IS (360/P) - KAngS. // Ship angular speed acounted for Body rotation.
    LOCAL TgtLong IS utilAngleTo360(lng).
    LOCAL ShipLong is utilAngleTo360(SHIP:LONGITUDE). 
    LOCAL DLong IS TgtLong - ShipLong. 
    IF DLong < 0 {
        RETURN (DLong + 360) / SAngS. 
    }
    ELSE {
        RETURN DLong / SAngS.
    }
}

function planeDeorbit {
    LOCAL Landing_Lng IS -75.
    LOCAL DeorbitRad is ship:body:radius - 3000.

    LOCAL r1 is ship:orbit:semimajoraxis.                               //Orbit now
    LOCAL r2 is DeorbitRad .                                            // Target orbit
    LOCAL pt is 0.5 * ((r1+r2) / (2*r2))^1.5.                           // How many orbits of a target in the target (deorbit) orbit will do.
    LOCAL sp is SQRT( ( 4 * constant:pi^2 * r2^3 ) / body:mu ).         // Period of the target orbit.
    LOCAL DeorbitTravelTime is pt*sp /2.                                // Transit time 
    LOCAL phi is (DeorbitTravelTime/ship:body:rotationperiod) * 360.    // Phi in this case is not the angle between two orbits, but the angle the body rotates during the transit time
    LOCAL Deorbit_Long to utilAngleTo360(Landing_Lng - 145).

    mainframeChangePeriapsis(-3000, time + planeTimeToLong(Deorbit_Long+phi)).
}