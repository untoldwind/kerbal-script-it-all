RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/atmo/lib").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/plane/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").


//atmoLaunchAscent().
//vacLand(0, -60).
//vacHoverTo(0, -60, 100).

function launch {
    planeLaunchSSTO(150000).
    mainframeCircularize().
}

function pickup {
    SET TARGET TO "Meldun's Derelict".
    mainframeBiImplusive().
    mainframeMatchVelocities().
    rendezvousApproach().
}

function deorbit {
    LOCAL Landing_Lng IS -75.
    LOCAL DeorbitRad is ship:body:radius - 3000.

    LOCAL r1 is ship:orbit:semimajoraxis.                               //Orbit now
    LOCAL r2 is DeorbitRad .                                            // Target orbit
    LOCAL pt is 0.5 * ((r1+r2) / (2*r2))^1.5.                           // How many orbits of a target in the target (deorbit) orbit will do.
    LOCAL sp is SQRT( ( 4 * constant:pi^2 * r2^3 ) / body:mu ).         // Period of the target orbit.
    LOCAL DeorbitTravelTime is pt*sp /2.                                // Transit time 
    LOCAL phi is (DeorbitTravelTime/ship:body:rotationperiod) * 360.    // Phi in this case is not the angle between two orbits, but the angle the body rotates during the transit time
    LOCAL Deorbit_Long to utilAngleTo360(Landing_Lng - 145).

    mainframeChangePeriapsis(-3000, time + landTimeToLong(Deorbit_Long+phi)).
}

LOCAL RunwayFAR IS LATLNG(-0.0486, -80).

function aeroBreak {
    planeSwitchAtmo().
    partsRetractSolarPanels().
    partsRetractAntennas().

    SAS off.

    LOCK STEERING TO HEADING(RunwayFAR:HEADING, 30).

    physWarp(1).

    WAIT UNTIL SHIP:ALTITUDE < 23000 or SHIP:VELOCITY:SURFACE:MAG < 1200.

    UNLOCK STEERING.
}

function soarDown {
    SAS off.
    
    LOCAL PitchPID IS PIDLOOP(0.4,0.01,0.1,-10, 20).     
    LOCAL ThrottlePID IS PIDLOOP(0.04,0.001,0.01,0, 1). 
    LOCAL tgtVelocity IS 800.
    LOCAL tgtAlt IS 12000.
    LOCAL tgtPitch IS 0.
    LOCAL tgtThrottle IS 0.

    LOCK STEERING TO HEADING(RunwayFAR:HEADING, 0).
    LOCK THROTTLE TO tgtThrottle.

    UNTIL SHIP:GEOPOSITION:LNG < 0 AND SHIP:GEOPOSITION:LNG > -85 {
        WAIT 0.

        SET tgtThrottle TO ThrottlePID:UPDATE(TIME:SECONDS, SHIP:VELOCITY:SURFACE:MAG - tgtVelocity).
        SET tgtPitch TO PitchPID:UPDATE(TIME:SECONDS, tgtAlt - SHIP:ALTITUDE).
    }
}

//launch().
//pickup().
//deorbit().
//aeroBreak().
soarDown().