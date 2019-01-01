//Libraries
runoncepath("/core/lib_ui").
runoncepath("/plane/lib_parts").

function planeLaunchSSTO {
    //Parameters
    Parameter TGTApoapsis is 120000.
    Parameter TGTHeading is 90.

    LOCAL RunwayEnd IS LATLNG(-0.050, -74.4947394).

    // Global Variables.
    LOCAL LaunchSPV0 is ship:AIRSPEED.
    LOCAL LaunchSPT0 is time:SECONDS.

    // Local Variables.
    Local TGTAirSpeed is 1450.          // Target airspeed before switching to closed cycle
    Local ClimbTick is 0.25.            // Time between each loop run
    Local ClimbDefaultPitch is 20.      // Default climb pitch
    Local GTAltitude is 45000.          // End of "Gravit turn" (When ship will fly with pitch 0 until apoapsis)
    Local AirBreathingAlt is 23000.     // From this altitude and up, dual-mode engines will change to closed cycle. 
    Local ThrottleValue is 0.

    LOCAL toggleEngines IS planeMultiModeEngines().

    // Functions.
    function ClimbAcc {
        if time:SECONDS - LaunchSPT0 > 0 return (SHIP:AIRSPEED - LaunchSPV0 ) / (TIME:SECONDS - LaunchSPT0).
        else Return 0.
    }

    function TargetAcc {
        if SHIP:Altitude > AirBreathingAlt or SHIP:VERTICALSPEED < 0 return 7.
        local timeToModeSwitch is (AirBreathingAlt - Ship:Altitude) / SHIP:VERTICALSPEED.
        local tgtAcc is (TGTAirSpeed - SHIP:AIRSPEED) / timeToModeSwitch + 1.

        if tgtAcc < 3 return 3.
        return tgtAcc.
    }

    function ascentThrottle {
        // Ease thottle when near the Apoapsis
        local ApoPercent is ship:obt:apoapsis/TGTApoapsis.
        local ApoCompensation is 0.
        if ApoPercent > 0.9 set ApoCompensation to (ApoPercent - 0.9) * 10.
        return 1 - min(0.95,max(0,ApoCompensation)).  
    }

    when Ship:Altitude > AirBreathingAlt then {
        uiConsole("SSTO", "Toggle closed cycle").
        planeMMEngineClosedCycle().
        Return false.
    }

    when toggleEngines[0]:IGNITION and toggleEngines[0]:FLAMEOUT then {
        uiConsole("SSTO", "Switch vac").
        planeSwitchVac().
        return false.
    }

    // PID Loop.
    local CLimbPitchPID is PIDLOOP(1,0.4,0.6,-11,11). //kP, kI, kD, Min, Max
    set CLimbPitchPID:SetPoint to 0.

    // Main program

    // Take off
    clearscreen.
    STAGE.
    uiConsole("SSTO","Start engines...").
    planeDisarmsChutes().
    planeSwitchAtmo().
    BRAKES OFF.
    SAS OFF.
    RCS OFF.
    LIGHTS ON.
    BAYS OFF.
    INTAKES ON.

    Set ThrottleValue to 1.
    LOCK THROTTLE TO ThrottleValue.


    LOCK STEERING TO HEADING(RunwayEnd:HEADING, -2).

    WAIT UNTIL SHIP:AIRSPEED > 90.
    uiConsole("SSTO","Take off...").
    LOCK STEERING TO HEADING(TGTHeading, 10).

    WAIT UNTIL SHIP:ALTITUDE > 100.
    GEAR OFF.
    uiConsole("SSTO", "Positive climb, gear up.").

    // Climb to Apoapsis
    Local PitchAngle is 10.

    Local PitchByAcc is 0.
    Local PitchByGT is 0.

    Lock Steering to Heading (TGTHeading,PitchAngle).
    Lock PercentGT to MIN( 1, SHIP:ALTITUDE / GTAltitude).

    UNTIL SHIP:Apoapsis > TGTApoapsis or ship:altitude > body:atm:height {
        set LaunchSPT0 to Time:Seconds.
        set LaunchSPV0 to Ship:AIRSPEED.
        set ThrottleValue to ascentThrottle().
        wait ClimbTick.

        set PitchByGT to ArcCos(PercentGT).
        set PitchByAcc to ClimbDefaultPitch + CLimbPitchPID:UPDATE(Time:Seconds,TargetAcc()-ClimbAcc()).

        print "GT pitch : " + PitchByGT at (0, 20).
        print "Acc pitch: " + PitchByAcc at (0, 21).
        print "ClimbAcc : " + ClimbAcc() at (0, 22).
        print "TargetAcc: " + TargetAcc() at (0, 23).

        set PitchAngle to min(PitchByGT,PitchByAcc).
    } 
    Set ThrottleValue to 0.

    until ship:altitude > body:atm:height {
        if ship:obt:apoapsis < TGTApoapsis Set ThrottleValue to ascentThrottle().
        else set ThrottleValue to 0.
        wait ClimbTick.
    }

    Unlock Steering.
    Unlock Throttle.

    Panels On.
    Fuelcells On.
    Radiators On.
}