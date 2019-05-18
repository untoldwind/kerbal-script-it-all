CLEARGUIS().

LOCAL gui IS GUI(200).

LOCAL launchBox IS gui:ADDHBOX().
launchBox:ADDLABEL("Apoapsis:").
LOCAL launchApoField IS launchBox:ADDTEXTFIELD("90000").
LOCAL launchButton IS launchBox:AddButton("Launch").

LOCAL execNodeButton IS gui:AddButton("Exec node").

LOCAL isDone IS FALSE.
LOCAL script IS "".
LOCAL params IS 0.

function onLaunch {
    SET isDone TO TRUE.
    SET script TO "launch".
    SET params TO launchApoField:TEXT:TONUMBER(90000).
}

SET launchButton:ONCLICK TO onLaunch@.

function onExecNode {
    SET isDone TO TRUE.
    SET script TO "exec_node".
}

SET execNodeButton:ONCLICK TO onExecNode@.

UNTIL false {
    SET script TO "".
    SET params TO 0.
    SET isDone TO false.
    
    gui:Show().

    wait until isDone.

    gui:Hide().

    SWITCH TO CORE:VOLUME.

    runpath("/scripts/" + script, params).
}