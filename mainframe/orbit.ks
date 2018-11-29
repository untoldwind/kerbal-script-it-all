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

function mainframeCorrectTargetPeriapsis {
    parameter targetPeriapsis.

    uiConsole("MAINFRAME", "Correct Target Periapsis").
    if not HASTARGET or TARGET:TYPENAME <> "Body" {
        uiError("MAINFRAME", "No target body").
        return.
    }
    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHEAPEST_CORRECTION_BODY(TARGET, targetPeriapsis + TARGET:RADIUS).
    WAIT 0.

    mainframeExecNode().
}

function mainframeChangeApoapsis {
    uiConsole("MAINFRAME", "Change apapsis").
    parameter targetApoapsis.
    parameter atTime IS TIME + 20.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHANGE_APOAPSIS(atTime, BODY:RADIUS + targetApoapsis).
    WAIT 0.

    mainframeExecNode().
}

function mainframeChangePeriapsis {
    uiConsole("MAINFRAME", "Change periapsis").
    parameter targetPeriapsis.
    parameter atTime IS TIME + 20.

    utilRemoveNodes().

    ADD ADDONS:MainFrame:MANEUVERS:CHANGE_PERIAPSIS(atTime, BODY:RADIUS + targetPeriapsis).
    WAIT 0.

    mainframeExecNode().
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