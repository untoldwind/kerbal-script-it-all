RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/atmo/deorbit_simple").

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).
    orbitCirc().

    updateMissionState("inorbit").
} ELSE IF mission_state = "inorbit" {
    atmoDeorbitSimple().

    updateMissionState("done").
}