RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_inc_tgt").
RUNONCEPATH("/orbit/node_peri").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/atmo/deorbit_simple").

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(140000).
    orbitCirc().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Hayfel's Hulk".
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
    orbitNodePeri(30000).
    orbitExecNode().

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

	SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".

    updateMissionState("done").
}
