RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/transfer").
RUNONCEPATH("/orbit/node_return_from_moon").
RUNONCEPATH("/vac/land").
RUNONCEPATH("/vac/launch_ascent").

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
    SET TARGET TO "Mun".
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
    vacLand(0, -120).

    updateMissionState("landed").
} ELSE IF mission_state = "landed" {
    vacLaunchAscent(30000, 90).
    orbitCirc().

    updateMissionState("return_orbit").
}

IF mission_state = "return_orbit" {
    PRINT "Do return".
    orbitNodeReturnFromMoon(800000).
    orbitExecNode().

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    orbitTransfer().

    IF SHIP:ORBIT:PERIAPSIS < 40000 {
        LOCK STEERING TO SHIP:PROPAGATE.

        WAIT UNTIL utilIsShipFacing(SHIP:PROPAGATE).

        LOCK THROTTLE TO 0.3.

        UNTIL SHIP:ORBIT:PERIAPSIS > 40000 {
            stagingCheck().
            wait 0.1.
        }
    } ELSE {
        LOCK STEERING TO SHIP:RETROGRADE.

        WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

        LOCK THROTTLE TO 0.3.

        UNTIL SHIP:ORBIT:PERIAPSIS < 40000 {
            stagingCheck().
            wait 0.1.
        }
    }

    UNLOCK all.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }

	SAS on.
	SET NAVMODE TO "SURFACE".

	WAIT 5.
	
	SET SASMODE TO "RETROGRADE".

    partsRetractAntennas().
    partsRetractSolarPanels().
    updateMissionState("done").
}
