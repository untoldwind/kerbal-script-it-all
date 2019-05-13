RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib").

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

mainframeEnsure().

IF mission_state = "launch" {
    PRINT "Launch sequence".
    atmoLaunchAscent(102000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
    SET TARGET TO Minmus.
    mainframeHohmann().

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
    for p in SHIP:PARTS {
        if p:NAME:CONTAINS("SkyCrane") {
            LOCAL m IS p:GETMODULE("ModuleAnimateGeneric").
            if m:HASEVENT("extend engines") {
                m:DOEVENT("extend engines").
            }
        }
    }

    UNTIL STAGE:NUMBER = 0 {
        WAIT UNTIL STAGE:READY.
        STAGE.
    }
    LOCAL LandSite IS WAYPOINT("Minmus Landing"):GEOPOSITION.
    vacLand(LandSite:LAT, LandSite:LNG, true, -1).

    updateMissionState("Done").
}