RUNONCEPATH("/core/lib_util").

function planeFlyTo {
    parameter targetVec.
    parameter tgtSpeed.

    LOCAL throttlePID TO  PIDLOOP(0.1,0.001,0.05,0,1).
    LOCAL pitchPID TO  PIDLOOP(0.8,0.02,0.2,-10,20).
    LOCAL pitch TO 10.
    LOCAL throttleValue TO 0.

    function easeHeading {
        LOCAL speedHeading IS planeHeadingOf(SHIP:VELOCITY:SURFACE).
        LOCAL targetHeading IS planeHeadingOf(targetVec + BODY:POSITION).
        LOCAL diff IS utilAngleTo360(targetHeading - speedHeading + 180) - 180.

        if diff < -10 {
            SET diff TO -10.
        }
        if diff > 10 {
            SET diff TO 10.
        }
        return speedHeading + diff.
    }

    print easeHeading().

    LOCK tgtHeading TO easeHeading().
    LOCK distance TO VXCL(SHIP:UP:VECTOR, targetVec + BODY:POSITION):MAG.
    LOCK steerDir TO HEADING(tgtHeading, pitch).
    LOCK STEERING TO steerDir.
    LOCK THROTTLE TO throttleValue.

    function tgtVerticalSpeed {
        LOCAL dT IS distance / SHIP:VELOCITY:SURFACE:MAG.
        LOCAL altDiff IS SHIP:UP:VECTOR * (targetVec + BODY:POSITION).

        return altDiff / dT.
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
    }

    UNLOCK STEERING.
    UNLOCK THROTTLE.
}