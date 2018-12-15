
function planeLand {
    parameter runwayStart IS KSCRunwayStart.
    parameter runwayEnd IS KSCRunwayEnd.
    parameter landingSpeed IS 100.
    parameter landingVSpeed IS 5.

    LOCAL runwayStartPos IS runwayStart:ALTITUDEPOSITION(runwayStart:TERRAINHEIGHT + 1) - BODY:POSITION.
    LOCAL runwayDirVec IS (runwayEnd:ALTITUDEPOSITION(runwayStart:TERRAINHEIGHT + 1) - runwayStart:ALTITUDEPOSITION(runwayStart:TERRAINHEIGHT + 1)):NORMALIZED.
    LOCAL touchdownPos IS runwayStartPos + runwayDirVec * 0.1.
    LOCAL runwayUp IS runwayStartPos:NORMALIZED.
    LOCAL ilsFinalTime IS 5000 / landingSpeed.
    LOCAL ilsFinalStartPos IS (-runwayDirVec * landingSpeed + runwayUp * landingVSpeed) * ilsFinalTime + touchdownPos. 
    LOCAL ilsNearStartPos IS (-runwayDIrVec * 40000 + runwayUp * 4000) + ilsFinalStartPos.
    LOCAL ilsFarStartPos IS (-runwayDirVec * 50000 + runwayUp * 6000) + ilsNearStartPos.
    LOCAL ilsPart IS 2.

    function ilsVec {
        parameter part.

        if part <= 0 {
            return touchdownPos.
        }
        if part < 1 {
            return (ilsNearStartPos - runwayStartPos) * part + ilsFinalStartPos.
        }
        return (ilsFarStartPos - ilsNearStartPos) * (part - 1) + ilsNearStartPos.
    }

    LOCAL targetVec IS ilsVec(ilsPart).
    LOCAL tgtSpeed IS 500.
    LOCAL throttlePID TO  PIDLOOP(0.1,0.001,0.05,0,1).
    LOCAL pitchPID TO  PIDLOOP(0.8,0.02,0.2,-10,20).
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

    UNTIL SHIP:STATUS = "LANDED" {
        SET throttleValue TO throttlePID:UPDATE(TIME:SECONDS, SHIP:AIRSPEED - tgtSpeed).
        SET pitch TO pitchPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED - tgtVerticalSpeed()).

        IF (distance < 10000 and ilsPart > 1) or (distance < 5000 and ilsPart > 0) {
            SET ilsPart TO ilsPart - 0.1.
            if ilsPart < 1 {
                SET tgtSpeed TO (1 + 2 * ilsPart) * landingSpeed.
            }            
            SET targetVec TO ilsVec(ilsPart).

            IF ilsPart <= 0 {
                SET tgtSpeed TO landingSpeed.
                GEAR on.
            }
        }

        planeDebugVectors(steerDir, targetVec + BODY:POSITION).

        print "Distance : " + distance + "                  "  at(0,0).
        print "TgtVSpeed: " + tgtVerticalSpeed() + "                  "  at(0,1).
        print "VSpeed   : " + SHIP:VERTICALSPEED + "                  "  at(0,2).
        print "TgtSpeed : " + tgtSpeed + "                  "  at(0,3).
        print "Speed    : " + SHIP:AIRSPEED + "                  "  at(0,4).
        print "Pitch    : " + pitch + "                  "  at(0,5).
        print "Roll     : " + roll + "                  "  at(0,6).
        print "hdgDiff  : " + headingDiff + "                  "  at(0,7).
        print "speedHeading  : " + speedHeading + "                  "  at(0,8).
        print "targetHeading  : " + targetHeading + "                  "  at(0,9).

        WAIT 0.1.
    }

    BREAKS on.
    SET throttleValue TO 0.
    LOCK STEERING TO HEADING(runwayEnd:HEADING, 0).

    WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 0.1.

    UNLOCK STEERING.
    UNLOCK THROTTLE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}