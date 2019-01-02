RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/mainframe/exec_node").

function mainframeCircularize {
    uiConsole("MAINFRAME", "Circularize").
    utilRemoveNodes().
    ADD ADDONS:MainFrame:MANEUVERS:CIRCULARIZE.
    WAIT 0.

    mainframeExecNode().
}

function mainframeMatchPlanes {
    uiConsole("MAINFRAME", "Match planes").
    if not HASTARGET {
        uiError("MAINFRAME", "No target").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:MATCH_PLANES(TARGET).
    WAIT 0.

    mainframeExecNode().
}

function mainframeHohmann {
    uiConsole("MAINFRAME", "Hohmann").
    if not HASTARGET {
        uiError("MAINFRAME", "No target").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:HOHMANN_LAMBERT(TARGET, 0).
    WAIT 0.

    mainframeExecNode().
}

function mainframeBiImplusive {
    uiConsole("MAINFRAME", "BiImpulsive").
    if not HASTARGET {
        uiError("MAINFRAME", "No target").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:BIIMPULSIVE(TARGET).
    WAIT 0.

    mainframeExecNode().
}

function mainframeMatchVelocities {
    uiConsole("MAINFRAME", "Match velocities").
    if not HASTARGET {
        uiError("MAINFRAME", "No target").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:MATCH_VELOCITIES(TARGET).
    WAIT 0.

    mainframeExecNode().
}

function mainframeCorrectTarget {
    parameter exec IS true.

    uiConsole("MAINFRAME", "Correct Target").
    if not HASTARGET or TARGET:TYPENAME <> "Body" {
        uiError("MAINFRAME", "No target body").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHEAPEST_CORRECTION(TARGET).

    IF exec {
        WAIT 0.

        mainframeExecNode().
    } ELSE IF ADDONS:AVAILABLE("KAC") {
        SET alarm TO addAlarm("ManeuverAuto", TIME:SECONDS + NEXTNODE:ETA - 600, ship:NAME, "Couse correction to " + target:Name).
        SET alarm:MARGIN TO 600.
    }
}

function mainframeCorrectTargetPeriapsis {
    parameter targetPeriapsis.
    parameter exec IS true.

    uiConsole("MAINFRAME", "Correct Target Periapsis").
    if not HASTARGET or TARGET:TYPENAME <> "Body" {
        uiError("MAINFRAME", "No target body").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHEAPEST_CORRECTION_BODY(TARGET, targetPeriapsis + TARGET:RADIUS).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    } ELSE IF ADDONS:AVAILABLE("KAC") {
        SET alarm TO addAlarm("ManeuverAuto", TIME:SECONDS + NEXTNODE:ETA - 600, ship:NAME, "Couse correction to " + target:Name).
        SET alarm:MARGIN TO 600.
    }
}

function mainframeChangeApoapsis {
    uiConsole("MAINFRAME", "Change apapsis").
    parameter targetApoapsis.
    parameter atTime IS TIME + 20.
    parameter exec IS TRUE.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHANGE_APOAPSIS(atTime, BODY:RADIUS + targetApoapsis).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    }
}

function mainframeChangePeriapsis {
    uiConsole("MAINFRAME", "Change periapsis").
    parameter targetPeriapsis.
    parameter atTime IS TIME + 20.
    parameter exec IS TRUE.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHANGE_PERIAPSIS(atTime, BODY:RADIUS + targetPeriapsis).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    }
}

function mainframeChangeInclination {
    uiConsole("MAINFRAME", "Change inclination").
    parameter targetInclination.
    parameter atTime IS TIME + 20.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHANGE_INCLINATION(atTime, targetInclination).
    WAIT 0.

    mainframeExecNode().
}

function mainframeReturnFromMoon {
    parameter targetPeriapsis.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:RETURN_FROM_MOON(targetPeriapsis).
    WAIT 0.

    mainframeExecNode().
}

function mainframeInterplanetary {
    parameter exec IS TRUE.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:INTERPLANETARY(target, true).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    } ELSE IF ADDONS:AVAILABLE("KAC") {
        SET alarm TO addAlarm("ManeuverAuto", TIME:SECONDS + NEXTNODE:ETA - 600, ship:NAME, "Exit orbit to " + target:Name).
        SET alarm:MARGIN TO 600.
    }
}
function mainframeInterplanetaryLambert {
    parameter exec IS TRUE.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:INTERPLANETARY_LAMBERT(target).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    } ELSE IF ADDONS:AVAILABLE("KAC") {
        SET alarm TO addAlarm("ManeuverAuto", TIME:SECONDS + NEXTNODE:ETA - 600, ship:NAME, "Exit orbit to " + target:Name).
        SET alarm:MARGIN TO 600.
    }
}

function mainframeInterplanetaryBiImpulsive {
    parameter exec IS TRUE.
    parameter maxUT IS 7200000.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:INTERPLANETARY_BIIMPULSIVE(target, maxUT).
    IF exec {
        WAIT 0.

        mainframeExecNode().
    } ELSE IF ADDONS:AVAILABLE("KAC") {
        SET alarm TO addAlarm("ManeuverAuto", TIME:SECONDS + NEXTNODE:ETA - 600, ship:NAME, "Exit orbit to " + target:Name).
        SET alarm:MARGIN TO 600.
    }
}