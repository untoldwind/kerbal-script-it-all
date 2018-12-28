RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib").


SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    LIGHTS ON.
    PRINT "Launch sequence".
    atmoLaunchAscent(120000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO Minmus.
    mainframeBiImplusive().

    updateMissionState("intransit_mun").
}

IF mission_state = "intransit_mun" {
    mainframeCorrectTargetPeriapsis(100000).

    updateMissionState("corrected_transit").
}

IF mission_state = "corrected_transit" {
    mainframeTransfer().

    updateMissionState("entered_munsoi").
}

IF mission_state = "entered_munsoi" {
    mainframeChangePeriapsis(60000).
    mainframeCircularize().

    updateMissionState("inorbit_mun").
}

IF mission_state = "inorbit_mun" {
    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }
    SET TARGET TO "Minmus Assembly".
    LOCAL LandSite IS TARGET:GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG, true, -1, true).

    updateMissionState("done").
}