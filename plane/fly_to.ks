RUNONCEPATH("/core/lib_util").

function planeFlyTo {
    parameter targetVec.
    parameter tgtSpeed.

    LOCAL throttlePID TO  PIDLOOP(0.1,0.001,0.05,0,1).
    LOCAL pitchPID TO  PIDLOOP(0.8,0.05,0.6,-10,20).
    LOCAL roll TO 0.
    LOCAL pitch TO 10.
    LOCAL throttleValue TO 0.

    LOCK speedHeading TO planeHeadingOf(SHIP:VELOCITY:SURFACE).
    LOCK targetHeading TO planeHeadingOf(targetVec + BODY:POSITION).
    LOCK headingDiff TO utilAngleTo360(targetHeading - speedHeading + 180) - 180.
    LOCK steerHeading TO speedHeading + MAX(-10, MIN(10, headingDiff)).
    LOCK roll TO MAX(-45, MIN(45, -headingDiff)).
    LOCK distance TO VXCL(SHIP:UP:VECTOR, targetVec + BODY:POSITION):MAG.
    LOCK steerDir TO HEADING(steerHeading, pitch) + R(0,0,roll).
    LOCK STEERING TO steerDir.
    LOCK THROTTLE TO throttleValue.

    function tgtVerticalSpeed {
        LOCAL dT IS distance / SHIP:VELOCITY:SURFACE:MAG.
        LOCAL targetAlt IS BODY:ALTITUDEOF(targetVec + BODY:POSITION).

        return (targetAlt - SHIP:ALTITUDE) / dT.
    }

    UNTIL distance < 1000 {
        SET throttleValue TO throttlePID:UPDATE(TIME:SECONDS, SHIP:AIRSPEED - tgtSpeed).
        SET pitch TO pitchPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED - tgtVerticalSpeed()).

        planeDebugVectors(steerDir, targetVec + BODY:POSITION).

        print "Distance : " + distance + "                  "  at(0,0).
        print "TgtVSpeed: " + tgtVerticalSpeed() + "                  "  at(0,1).
        print "VSpeed   : " + SHIP:VERTICALSPEED + "                  "  at(0,2).
        print "TgtSpeed : " + tgtSpeed + "                  "  at(0,3).
        print "Speed    : " + SHIP:AIRSPEED + "                  "  at(0,4).
        print "Pitch    : " + pitch + "                  "  at(0,5).
        print "Roll     : " + roll + "                  "  at(0,6).
        WAIT 0.1.
    }

    UNLOCK STEERING.
    UNLOCK THROTTLE.
}