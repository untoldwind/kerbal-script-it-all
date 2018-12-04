RUNONCEPATH("/mainframe/orbit").
RUNONCEPATH("/mainframe/transfer").
RUNONCEPATH("/core/lib_ui").

function mainframeEnsure {
    IF not ADDONS:AVAILABLE("MainFrame") {
        uiFatal("kOS MainFrame not available").
    }
}
