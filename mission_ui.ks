parameter mission.

GLOBAL mission_state IS "launch".
GLOBAL FUNCTION updateMissionState {
    parameter state.

    LOCAL store IS LEXICON().
    
    store:ADD("state", state).
    SET mission_state TO state.

    WRITEJSON(store, "/current_state.json").

    IF kUniverse:CANQUICKSAVE {
         kUniverse:QUICKSAVE().
    }
}

FUNCTION readMissionState {
    IF NOT EXISTS("/current_state.json") or SHIP:STATUS = "PRELAUNCH" {
        return "launch".
    }
    LOCAL store IS READJSON("/current_state.json").

    return store["state"].
}

SET mission_state TO readMissionState().

CLEARGUIS().

LOCAL gui IS GUI(200).
LOCAL missionBox IS gui:ADDHBOX().
missionBox:ADDLABEL("Mission:").
LOCAL missionLabel IS missionBox:ADDLABEL(mission).
SET missionLabel:STYLE:ALIGN TO "CENTER".
SET missionLabel:STYLE:HSTRETCH TO True.
LOCAL stateBox IS gui:ADDHBOX().
stateBox:ADDLABEL("State:").
LOCAL stateLabel IS stateBox:ADDLABEL(mission_state).
SET stateLabel:STYLE:ALIGN TO "CENTER".
SET stateLabel:STYLE:HSTRETCH TO True.

LOCAL launchButton IS gui:AddButton("Launch").

LOCAL isDone IS FALSE.
function onLaunch {
    SET isDone TO TRUE.
}

SET launchButton:ONCLICK TO onLaunch@.

UNTIL mission_state = "done" {
    IF mission_state <> "launch" {
        SET launchButton:TEXT TO "Continue".
    }
    SET stateLabel:TEXT TO mission_state.
    SET isDone TO false.

    gui:Show().

    wait until isDone.

    gui:HIDE().

    SWITCH TO CORE:VOLUME.

    runpath("/missions/" + mission + "/launch").
}

IF SHIP:CREW:LENGTH > 0 {
    PRINT "End of program. You're on your own now: " + SHIP:CREW[0]:NAME.
}