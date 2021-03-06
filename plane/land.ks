
function planeLand {
    parameter runwayStart IS KSCRunwayStart.
    parameter runwayEnd IS KSCRunwayEnd.
    parameter landingSpeed IS 100.
    parameter landingVSpeed IS 3.

    planeSwitchAtmo().
    partsRetractSolarPanels().
    partsRetractAntennas().

    LOCAL DrawDebugVectors is false.
    LOCAL runwayStartPos IS runwayStart:ALTITUDEPOSITION(runwayStart:TERRAINHEIGHT + 1) - BODY:POSITION.
    LOCAL runwayEndPos IS runwayEnd:ALTITUDEPOSITION(runwayEnd:TERRAINHEIGHT + 1) - BODY:POSITION.
    LOCAL runwayDirVec IS (runwayEndPos - runwayStartPos):NORMALIZED.
    LOCAL touchdownPos IS runwayStartPos - runwayDirVec * 0.2.
    LOCAL runwayUp IS runwayStartPos:NORMALIZED.
    LOCAL ilsFinalTime IS 5000 / landingSpeed.
    LOCAL ilsFinalStartPos IS (-runwayDirVec * landingSpeed + runwayUp * landingVSpeed) * ilsFinalTime + touchdownPos. 
    LOCAL ilsNearStartPos IS (-runwayDIrVec * 40000 + runwayUp * 4000) + ilsFinalStartPos.
    LOCAL ilsFarStartPos IS (-runwayDirVec * 50000 + runwayUp * 5000) + ilsNearStartPos.
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
    LOCAL glideVec IS V(0,0,0).
    LOCAL tgtSpeed IS 600.
    LOCAL throttlePID TO  PIDLOOP(0.05,0.001,0.05,0,1).
    LOCAL pitchPID TO  PIDLOOP(0.8,0.05,0.6,-15,20).
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

    function calcGlideDiff {
        if glideVec:MAG = 0 {
            return 0.
        }
        LOCAL dT IS distance / SHIP:VELOCITY:SURFACE:MAG / 2.
        LOCAL glideAlt IS BODY:ALTITUDEOF(targetVec + BODY:POSITION + distance * glideVec).

        return (glideAlt - SHIP:ALTITUDE) / dT.
    }

    function calcTgtVerticalSpeed {
        LOCAL dT IS distance / SHIP:VELOCITY:SURFACE:MAG.
        LOCAL targetAlt IS BODY:ALTITUDEOF(targetVec + BODY:POSITION).

        return (targetAlt - SHIP:ALTITUDE) / dT.
    }

    LOCK tgtVerticalSpeed TO calcTgtVerticalSpeed() + calcGlideDiff().

    UNTIL SHIP:ALTITUDE < 500 and SHIP:VERTICALSPEED > -1 {
        SET throttleValue TO throttlePID:UPDATE(TIME:SECONDS, SHIP:AIRSPEED - tgtSpeed).
        SET pitch TO pitchPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED - tgtVerticalSpeed).

        IF (distance < 10000 and ilsPart > 1) or (distance < 5000 and ilsPart > 0) {
            SET ilsPart TO ilsPart - 0.1.
            if ilsPart < 1 {
                SET tgtSpeed TO (1 + 3 * ilsPart) * landingSpeed.
            }
            IF ilsPart < 0.5 {
                SET glideVec TO (targetVec - ilsVec(ilsPart)):NORMALIZED.
            }
            SET targetVec TO ilsVec(ilsPart).

            IF ilsPart <= 0 {
                SET tgtSpeed TO landingSpeed.
                GEAR on.
            }
        } ELSE IF(distance < 800 and ilsPart <= 0) {
            LOCK roll TO 0.
            LOCK steerHeading TO runwayEnd:HEADING.
            LOCK tgtVerticalSpeed TO -landingVSpeed.
        }

        if DrawDebugVectors {
            planeDebugVectors(steerDir, targetVec + BODY:POSITION).

            print "Distance : " + distance + "                  "  at(0,0).
            print "TgtVSpeed: " + tgtVerticalSpeed + "                  "  at(0,1).
            print "VSpeed   : " + SHIP:VERTICALSPEED + "                  "  at(0,2).
            print "TgtSpeed : " + tgtSpeed + "                  "  at(0,3).
            print "Speed    : " + SHIP:AIRSPEED + "                  "  at(0,4).
            print "Pitch    : " + pitch + "                  "  at(0,5).
            print "Roll     : " + roll + "                  "  at(0,6).
            print "hdgDiff  : " + headingDiff + "                  "  at(0,7).
            print "speedHeading  : " + speedHeading + "                  "  at(0,8).
            print "targetHeading  : " + targetHeading + "                  "  at(0,9).
            print "glideDiff  : " + calcGlideDiff() + "                  "  at(0,10).
        }

        WAIT 0.1.
    }

    BRAKES on.
    CHUTES on.
    SET throttleValue TO 0.
    LOCK STEERING TO HEADING(runwayEnd:HEADING, 0).

    WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 0.1.

    UNLOCK STEERING.
    UNLOCK THROTTLE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}