RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/vac2/land").

function vacHoverTo {
    parameter LandLat is 0.
    parameter LandLng is 0.
    parameter hoverAlt is 500.

    LOCK FZ TO SHIP:UP:VECTOR.
    LOCK FX TO SHIP:NORTH:VECTOR.
    LOCK FY TO VCRS(FX, FZ).

    SAS off.
    LOCAL LandingSite is LATLNG(LandLat,LandLng).

    uiConsole("VACHOVER", "hoverTo").

    LOCAL ThrottlePID IS PIDLOOP(0.4,0.05,0.1). // Kp, Ki, Kd
    SET ThrottlePID:MAXOUTPUT TO 1.
    SET ThrottlePID:MINOUTPUT TO 0.
    SET ThrottlePID:SETPOINT TO 0. 

    LOCAL hCorrectX IS pidloop(0.4, 0.1, 0.2, -0.3, 0.3).
    LOCAL hCorrectY IS pidloop(0.4, 0.1, 0.2, -0.3, 0.3).

    LOCAL function calcHDist {
        return V(
            FX * LandingSite:POSITION,
            FY * LandingSite:POSITION,
            0
        ).
    }

    LOCAL function calcHVelocity {
        return V(
            FX * Ship:VELOCITY:SURFACE,
            FY * Ship:VELOCITY:SURFACE,
            0
        ).
    }

    SET steerDir TO V(0, 0, 1):DIRECTION.
    LOCAL throttleVal is 0.
    LOCK STEERING TO steerDir.
    LOCK THROTTLE to throttleVal.

    SET steerDir TO SHIP:UP.

    LOCK HDIST to calcHDist().
    LOCK ShipHVelocity to calcHVelocity().
    LOCK radarAlt TO landRadarAltimeter().

    until HDIST:MAG < 1 and ShipHVelocity:MAG < 1 {
        wait 0.

        LOCAL TargetVSpeed IS 0.
        IF hoverAlt > radarAlt {
            set TargetVSpeed TO SQRT(hoverAlt - radarAlt).
        } else IF hoverAlt < radarAlt {
            set TargetVSpeed TO -SQRT(radarAlt - hoverAlt).
        }
        
        LOCAL targetHX IS MAX(-10, MIN(10, HDIST:X / 15)).
        LOCAL targetHY IS MAX(-10, MIN(10, HDIST:Y / 15)).

        LOCAL dx IS hCorrectX:UPDATE(TIME:SECONDS, ShipHVelocity:X - targetHX ).
        LOCAL dy IS hCorrectY:UPDATE(TIME:SECONDS, ShipHVelocity:Y - targetHY ).
        LOCAL delta IS dx * FX + dy * FY.

        SET steerDir TO (SHIP:UP:VECTOR + delta):DIRECTION.

        set throttleVal TO ThrottlePID:UPDATE(TIME:seconds, Ship:VERTICALSPEED - TargetVSpeed).

        PRINT "UP " + SHIP:UP  + "                           " at (0,0).
        PRINT "Vertical speed " + Ship:VERTICALSPEED + "                           " at (0,1).
        Print "Target Vspeed  " + TargetVSpeed            + "                           " at (0,2).
        print "Throttle       " + throttleVal             + "                           " at (0,3).
        print "HDIST          " + HDIST        + "                           " at (0,4).
        print "HVel           " + ShipHVelocity + "                           " at (0,5).
        print "targetHX           " + targetHX + "                           " at (0,6).
        print "targetHY           " + targetHY + "                           " at (0,7).
        print "dx           " + dx + "                           " at (0,8).
        print "dy           " + dy + "                           " at (0,9).
        print "Ship height    " + radarAlt                + "                           " at (0,10).
        print "                                                                    " at (0,11).
    }

    UNTIL radarAlt < 100 AND Ship:VERTICALSPEED >= 0 {
        WAIT 0.
        set TargetVSpeed to MIN(-1, 5 - sqrt(radarAlt)).
        LOCAL targetHX IS 0.

        LOCAL targetHX IS MAX(-10, MIN(10, HDIST:X / 15)).
        LOCAL targetHY IS MAX(-10, MIN(10, HDIST:Y / 15)).

        LOCAL dx IS hCorrectX:UPDATE(TIME:SECONDS, ShipHVelocity:X - targetHX ).
        LOCAL dy IS hCorrectY:UPDATE(TIME:SECONDS, ShipHVelocity:Y - targetHY ).
        LOCAL delta IS dx * FX + dy * FY.

        SET steerDir TO (SHIP:UP:VECTOR + delta):DIRECTION.

        set throttleVal TO ThrottlePID:UPDATE(TIME:seconds, Ship:VERTICALSPEED - TargetVSpeed).

        PRINT "UP " + SHIP:UP  + "                           " at (0,0).
        PRINT "Vertical speed " + Ship:VERTICALSPEED + "                           " at (0,1).
        Print "Target Vspeed  " + TargetVSpeed            + "                           " at (0,2).
        print "Throttle       " + throttleVal             + "                           " at (0,3).
        print "HDIST          " + HDIST        + "                           " at (0,4).
        print "HVel           " + ShipHVelocity + "                           " at (0,5).
        print "targetHX           " + targetHX + "                           " at (0,6).
        print "targetHY           " + targetHY + "                           " at (0,7).
        print "dx           " + dx + "                           " at (0,8).
        print "dy           " + dy + "                           " at (0,9).
        print "Ship height    " + radarAlt                + "                           " at (0,10).
        print "                                                                    " at (0,11).
    }

    UNLOCK THROTTLE. UNLOCK STEERING.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SAS on.
}