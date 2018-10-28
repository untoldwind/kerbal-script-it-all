parameter mission.

LOCAL gui IS GUI(200).
LOCAL missionBox IS gui:ADDHBOX().
missionBox:ADDLABEL("Mission:").
LOCAL missionLabel IS missionBox:ADDLABEL(mission).
SET missionLabel:STYLE:ALIGN TO "CENTER".
SET missionLabel:STYLE:HSTRETCH TO True.
LOCAL launchButton IS gui:AddButton("Launch").

gui:Show().

LOCAL isDone IS FALSE.
function onLaunch {
    SET isDone TO TRUE.
}

SET launchButton:ONCLICK TO onLaunch@.

wait until isDone.

gui:HIDE().

SWITCH TO CORE:VOLUME.

runpath("/missions/" + mission + "/launch").
