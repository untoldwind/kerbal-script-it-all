RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/mainframe/exec_node").

function mainframeCircularize {
    uiConsole("MAINFRAME", "Circularize").
    utilRemoveNodes().
    ADD ADDONS:MainFrame:MANEUVERS:CIRCULARIZE.
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

    ADD ADDONS:MainFrame:MANEUVERS:HOHMANN_LAMBERT(TARGET:ORBIT, 0).
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

    ADD ADDONS:MainFrame:MANEUVERS:MATCH_VELOCITIES(TARGET:ORBIT).
    WAIT 0.

    mainframeExecNode().
}