RUNONCEPATH("/core/lib_parts").
RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/core/lib_staging").
RUNONCEPATH("/core/launch_ascent").
RUNONCEPATH("/orbit/circ").
RUNONCEPATH("/orbit/node_hoh").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/transfer").
RUNONCEPATH("/orbit/node_return_from_moon").

PRINT mission_state.

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    coreLaunchAscent().

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

    PRINT "At target, do all experiments".

    FOR experiment in SHIP:MODULESNAMED("ModuleScienceExperiment") {
        experiment:DEPLOY.
    }

    WAIT 5.

    PRINT "You may now enjoy the view".
} ELSE IF mission_state = "at_target" {
    PRINT "Do return".
    orbitNodeReturnFromMoon(800000).
    orbitExecNode().

    updateMissionState("transfer_back").
}

IF mission_state = "transfer_back" {
    orbitTransfer().

    IF SHIP:ORBIT:PERIAPSIS < 90000 {
        LOCK STEERING TO SHIP:PROPAGATE.

        WAIT UNTIL utilIsShipFacing(SHIP:PROPAGATE).

        LOCK THROTTLE TO 0.5.

        UNTIL SHIP:ORBIT:PERIAPSIS > 90000 {
            stagingCheck().
            wait 0.1.
        }
    } ELSE {
        LOCK STEERING TO SHIP:RETROGRADE.

        WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

        LOCK THROTTLE TO 0.5.

        UNTIL SHIP:ORBIT:PERIAPSIS < 90000 {
            stagingCheck().
            wait 0.1.
        }
    }

    UNLOCK all.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

    orbitCirc().

    updateMissionState("at_home").
}

IF mission_state = "at_home" {
    partsRetractAntennas().

    LOCK STEERING TO SHIP:RETROGRADE.

    WAIT UNTIL utilIsShipFacing(SHIP:RETROGRADE).

    LOCK THROTTLE TO 1.

    UNTIL SHIP:ALTITUDE < 70000 {
        stagingCheck().
        wait 0.5.
    }

    UNLOCK all.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

    STAGE.

    updateMissionState("done").
}
