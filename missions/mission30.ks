RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/atmo/deorbit_simple").

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(160000).
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Bartul's Capsule".
    orbitNodeHoh(10).
    orbitExecNode().

    updateMissionState("intransit").
}

IF mission_state = "intransit" {
    rendezvousNodeVelTgt().
    orbitExecNode().

    updateMissionState("neartarget").
}

IF mission_state = "neartarget" {
    UNTIL STAGE:NUMBER = 1 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    rendezvousApproach().
    updateMissionState("attarget").
} ELSE IF mission_state = "attarget" {
    atmoDeorbitSimple().

    updateMissionState("done").
}