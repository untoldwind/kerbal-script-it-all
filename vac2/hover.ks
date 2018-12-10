RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/vac2/land").

function vacHoverTo {
    parameter LandLat is 0.
    parameter LandLng is 0.
    parameter hoverAlt is 500.

    SAS off.
    LOCAL LandingSite is LATLNG(LandLat,LandLng).

    uiConsole("VACHOVER", "hoverTo").

    LOCAL ThrottlePID IS PIDLOOP(0.04,0.001,0.01). // Kp, Ki, Kd
    SET ThrottlePID:MAXOUTPUT TO 1.
    SET ThrottlePID:MINOUTPUT TO 0.
    SET ThrottlePID:SETPOINT TO 0. 

    LOCAL hCorrectX IS pidloop(0.04, 0.001, 0.03, -0.3, 0.3).
    LOCAL hCorrectY IS pidloop(0.04, 0.001, 0.03, -0.3, 0.3).

    LOCAL function calcHDist {
        LOCAL h IS vxcl(SHIP:UP:VECTOR,LandingSite:POSITION).
        SET H:Z TO 0.
        return h.
    }

    LOCAL function calcHVelocity {
        LOCAL h IS vxcl(SHIP:UP:VECTOR,Ship:VELOCITY:SURFACE).
        SET H:Z TO 0.
        return h.
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
        
        LOCAL targetHX IS HDIST:X / 10.
        LOCAL targetHY IS HDIST:Y / 10.

        LOCAL dx IS hCorrectX:UPDATE(TIME:SECONDS, ShipHVelocity:X - targetHX ).
        LOCAL dy IS hCorrectY:UPDATE(TIME:SECONDS, ShipHVelocity:Y - targetHY ).
        LOCAL delta IS V(dx, dy, 0).

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

    UNTIL radarAlt < 10 {
        set TargetVSpeed TO -1.
        LOCAL targetHX IS 0.

        LOCAL targetHX IS HDIST:X / 10.
        LOCAL targetHY IS HDIST:Y / 10.

        LOCAL dx IS hCorrectX:UPDATE(TIME:SECONDS, ShipHVelocity:X - targetHX ).
        LOCAL dy IS hCorrectY:UPDATE(TIME:SECONDS, ShipHVelocity:Y - targetHY ).
        LOCAL delta IS V(dx, dy, 0).

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