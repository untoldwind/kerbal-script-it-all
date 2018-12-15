
function planeTakeoff {
    parameter runwayEnd IS KSCRunwayEnd.
    parameter takeoffSpeed IS 90.

    LOCAL tgtHeading TO runwayEnd:HEADING.
    LOCAL tgtPitch TO 0.
    LOCAL tgtThrottle TO 0.

    STAGE.
    BRAKES OFF.
    SAS OFF.
    RCS OFF.
    LIGHTS ON.
    BAYS OFF.
    INTAKES ON.

    print tgtHeading.

    LOCK STEERING TO HEADING(tgtHeading, tgtPitch).
    LOCK THROTTLE TO 1.

    print takeoffSpeed.
    print THROTTLE.

    WAIT UNTIL SHIP:AIRSPEED > takeoffSpeed.

    SET tgtPitch TO 15.

    WAIT UNTIL planeRadarAltimeter() > 100.

    GEAR OFF.

    WAIT UNTIL planeRadarAltimeter() > 500.

    UNLOCK STEERING.
    UNLOCK THROTTLE.
}