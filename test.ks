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
    SET TARGET TO "Valrigh's Derelict".
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

function aeroBreak {
    planeSwitchAtmo().
    partsRetractSolarPanels().
    partsRetractAntennas().

    SAS off.

    LOCK STEERING TO HEADING(90, 30).

    physWarp(1).

    WAIT UNTIL SHIP:ALTITUDE < 23000 or SHIP:VELOCITY:SURFACE:MAG < 1200.

    UNLOCK STEERING.

    SAS on.
}

deorbit().
aeroBreak().
