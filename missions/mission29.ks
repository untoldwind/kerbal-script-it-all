RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_inc_tgt").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/atmo/deorbit_simple").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(140000).

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Jendas' Derelict".
    orbitNodeIncTgt().
    orbitExecNode().

    updateMissionState("inclinationmatched").
}

IF mission_state = "inclinationmatched" {
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