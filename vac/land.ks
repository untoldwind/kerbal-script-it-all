
RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/vac/lib_land").
RUNONCEPATH("/orbit/exec_node").

function vacLand {
    parameter LandLat is 0.
    parameter LandLng is 0.
    parameter landStage is 1.

    LOCAL DrawDebugVectors is true.

    SAS OFF.
    BAYS OFF.
    GEAR OFF.
    LADDERS OFF.

    if ship:status = "ORBITING" {
        SET LandingSite to LATLNG(LandLat,LandLng).

        //Define the deorbit periapsis
        local DeorbitRad to max(5000+ship:body:radius,(ship:body:radius*1.02 + LandingSite:terrainheight)).

        // Find a phase angle for the landing
        // The landing burning is like a Hohmann transfer, but to an orbit close to the body surface
        local r1 is ship:orbit:semimajoraxis.                               //Orbit now
        local r2 is DeorbitRad .                                            // Target orbit
        local pt is 0.5 * ((r1+r2) / (2*r2))^1.5.                           // How many orbits of a target in the target (deorbit) orbit will do.
        local sp is sqrt( ( 4 * constant:pi^2 * r2^3 ) / body:mu ).         // Period of the target orbit.
        local DeorbitTravelTime is pt*sp.                                   // Transit time 
        local phi is (DeorbitTravelTime/ship:body:rotationperiod) * 360.    // Phi in this case is not the angle between two orbits, but the angle the body rotates during the transit time
        local IncTravelTime is ship:obt:period / 4. // Travel time between change of inclinationa and lower perigee
        local phiIncManeuver is (IncTravelTime/ship:body:rotationperiod) * 360.

        // Deorbit and plane change longitudes
        Set Deorbit_Long to utilAngleTo360(LandLng - 180).
        Set PlaneChangeLong to utilAngleTo360(LandLng - 270).

        // Plane change for landing site
        local vel is velocityat(ship, landTimeToLong(PlaneChangeLong)):orbit.
        local inc is LandingSite:lat.
        local TotIncDV is 2 * vel:mag * sin(inc / 2).
        local nDv is vel:mag * sin(inc).
        local pDV is vel:mag * (cos(inc) - 1 ).

        if TotIncDV > 0.1 { // Only burn if it matters.
            uiDebug("Deorbit: Burning dV of " + round(TotIncDV,1) + " m/s @ anti-normal to change plane.").
            LOCAL nd IS NODE(time:seconds + landTimeToLong(PlaneChangeLong+phiIncManeuver), 0, -nDv, pDv).
            add nd. 
            orbitExecNode().
        }

        // Lower orbit over landing site
        local Deorbit_dV is landDeorbitDeltaV(DeorbitRad-body:radius).
        uiDebug("Deorbit: Burning dV of " + round(Deorbit_dV,1) + " m/s retrograde to deorbit.").
        LOCAL nd IS NODE(time:seconds + landTimeToLong(Deorbit_Long+phi) , 0, 0, Deorbit_dV).
        add nd. 
        orbitExecNode(). 
        uiDebug("Deorbit: Deorbit burn done"). 
        wait 5. // Let's have some time to breath and look what's happening 

        UNTIL STAGE:NUMBER = landStage {
            WAIT UNTIL STAGE:READY.
            STAGE.
        }
        WAIT 5.

        // Brake the ship to finally deorbit.
        SET BreakingDeltaV to VELOCITYAT(ship,time:seconds+eta:periapsis):orbit:mag.
        uiDebug("Deorbit: Burning dV of " + round(BreakingDeltaV,1) + " m/s retrograde to brake ship.").
        SET ND TO NODE(time:seconds + eta:periapsis , 0, 0, -BreakingDeltaV).
        add nd.
        
        orbitExecNode().
        uiDebug("Deorbit: Brake burn done").

    }
    ELSE IF SHIP:STATUS = "SUB_ORBITAL" {
        LOCK LandingSite TO SHIP:GEOPOSITION.
    }

    UNTIL STAGE:NUMBER = landStage {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    // Try to land
    if ship:status = "SUB_ORBITAL" or ship:status = "FLYING" {
        SET TouchdownSpeed to 2.

        //PID Throttle
        SET ThrottlePID to PIDLOOP(0.04,0.001,0.01). // Kp, Ki, Kd
        SET ThrottlePID:MAXOUTPUT TO 1.
        SET ThrottlePID:MINOUTPUT TO 0.
        SET ThrottlePID:SETPOINT TO 0. 

        SAS OFF.
        RCS OFF.
        LIGHTS ON. //We want the Kerbals to see where they are going right?
        LEGS ON.   //This is important!

        // Throttle and Steering
        local tVal is 0.
        lock Throttle to tVal.
        local sDir is ship:up.
        lock steering to sDir.

        // Main landing loop
        UNTIL SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED" {
            WAIT 0.
            // Steer the rocket
            SET radarAlt TO landRadarAltimeter().
            SET ShipVelocity TO SHIP:velocity:surface.
            SET ShipHVelocity to vxcl(SHIP:UP:VECTOR,ShipVelocity).
            Set DFactor TO 0.08. // How much the target position matters when steering. Higher values make landing more precise, but also may make the ship land with too much horizontal speed.
            SET TargetVector to vxcl(SHIP:UP:VECTOR,LandingSite:Position*DFactor).

            IF radarAlt < 1500 or ShipVelocity:MAG > 100 {
                SET TargetVector to V(0,0,0).
            }

            SET SteerVector to -ShipVelocity - ShipHVelocity + TargetVector.
            if DrawDebugVectors {
                SET DRAWSV TO VECDRAW(v(0,0,0),SteerVector, red, "Steering", 1, true, 1).
                SET DRAWV TO VECDRAW(v(0,0,0),ShipVelocity, green, "Velocity", 1, true, 1).
                SET DRAWHV TO VECDRAW(v(0,0,0),ShipHVelocity, YELLOW, "Horizontal Velocity", 1, true, 1).
                SET DRAWTV TO VECDRAW(v(0,0,0),TargetVector, Magenta, "Target", 1, true, 1).
            }
                
            set sDir TO SteerVector:Direction. 

            // Throttle the rocket
            set TargetVSpeed to MAX(TouchdownSpeed,sqrt(radarAlt)).

            IF abs(SHIP:VERTICALSPEED) > TargetVSpeed {
                set tVal TO ThrottlePID:UPDATE(TIME:seconds,(SHIP:VERTICALSPEED + TargetVSpeed)).
            }
            ELSE
            {
                set tVal TO 0.
            }

            if DrawDebugVectors { // I know, isn't the debug vectors but helps

                PRINT "Vertical speed " + abs(Ship:VERTICALSPEED) + "                           " at (0,0).
                Print "Target Vspeed  " + TargetVSpeed            + "                           " at (0,1).
                print "Throttle       " + tVal                    + "                           " at (0,2).
                print "Ship Velocity  " + ShipVelocity:MAG        + "                           " at (0,3).
                print "Ship height    " + landRadarAltimeter()        + "                           " at (0,4).
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
    else if ship:status = "ORBITING" uiError("Land","This ship is still in orbit!?").
    else if ship:status = "LANDED" or ship:status = "SPLASHED" uiError("Land","We are already landed, nothing to do here, move along").
    else uiError("Land","Can't land from " + ship:status).
}