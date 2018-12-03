RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/transfer").
RUNONCEPATH("/orbit/node_return_from_moon").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/orbit/node_inc_tgt").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.


PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).

    updateMissionState("circulating").
}

IF mission_state = "circulating" {
    PRINT "Launch sequence done. Begin circulating".
    orbitCirc().

    PRINT "Reached orbit.".

    updateMissionState("inorbit").
} 

IF mission_state = "inorbit" {
    SET TARGET TO Mun.
    orbitNodeHoh().
    orbitExecNode().

    PRINT "In transfer to Mun".

    updateMissionState("intransfer").
}

IF mission_state = "intransfer" {
    orbitTransfer().

    updateMissionState("circulating_target").
}

IF mission_state = "circulating_target" {
    PRINT "Reached Mun circulating".
    orbitCirc().

    PRINT "Reached orbit.".

    updateMissionState("at_target").

    PRINT "You may now enjoy the view".
} 

IF mission_state = "at_target" {
    SET TARGET TO "Hardock's Derelict".
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
    rendezvousApproach().
    updateMissionState("attarget").
} ELSE IF mission_state = "attarget" {
    SET TARGET TO "Lanmin's Shipwreck".

    orbitNodeIncTgt().
    orbitExecNode().

    updateMissionState("inclinationmatched2").
}

IF mission_state = "inclinationmatched2" {
    orbitCirc().

    updateMissionState("circulated2").
}

IF mission_state = "circulated2" {
    orbitNodeHoh(10).
    orbitExecNode().

    updateMissionState("intransit2").
}

IF mission_state = "intransit2" {
    rendezvousNodeVelTgt().
    orbitExecNode().

    updateMissionState("neartarget2").
}

IF mission_state = "neartarget2" {
    rendezvousApproach().
    updateMissionState("attarget2").
} ELSE IF mission_state = "attarget2" {
    orbitNodeReturnFromMoon(800000).
    orbitExecNode().

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    orbitTransfer().

    IF SHIP:ORBIT:PERIAPSIS < 80000 {
        LOCK STEERING TO SHIP:PROPAGATE.

        WAIT UNTIL utilIsShipFacing(SHIP:PROPAGATE).

        LOCK THROTTLE TO 0.3.

        UNTIL SHIP:ORBIT:PERIAPSIS > 80000 {
            stagingCheck().
            wait 0.1.
        }
    } ELSE {
        LOCK STEERING TO SHIP:RETROGRADE.

        WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

        LOCK THROTTLE TO 0.3.

        UNTIL SHIP:ORBIT:PERIAPSIS < 80000 {
            stagingCheck().
            wait 0.1.
        }
    }

    UNLOCK all.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

	SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".

    warpSeconds(ETA:PERIAPSIS - 120).

    SET THROTTLE TO 1.

    LIST ENGINES IN remaining_engines.

    WAIT UNTIL remaining_engines[0]:FLAMEOUT.

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

    partsRetractAntennas().
    partsRetractSolarPanels().
    updateMissionState("done").
}
