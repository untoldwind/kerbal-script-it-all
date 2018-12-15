runoncepath("/plane/lib_parts").

function planeAerobrake {
    planeSwitchAtmo().
    partsRetractSolarPanels().
    partsRetractAntennas().

    SAS off.

    LOCK STEERING TO HEADING(KSCRunwayStart:HEADING, 30).

    physWarp(1).

    WAIT UNTIL SHIP:ALTITUDE < 23000 or SHIP:VELOCITY:SURFACE:MAG < 1200.

    UNLOCK STEERING.

}