RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/rendezvous/node_vel_tgt").
RUNONCEPATH("/rendezvous/approach").
RUNONCEPATH("/atmo/deorbit_simple").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(160000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO "Trido's Capsule".
    mainframeHohmann().

    updateMissionState("intransit").
}

IF mission_state = "intransit" {
    mainframeMatchVelocities().

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