SWITCH TO ARCHIVE.

BRAKES off.

CLEARGUIS().

LOCAL gui IS GUI(200).
LOCAL script IS "".

function onTakeoff {
    SET script TO "test_takeoff".
}

LOCAL takeoffButton IS gui:AddButton("Takeoff").
SET takeoffButton:ONCLICK TO onTakeoff@.

function onFlyTo1 {
    SET script TO "test_flyto1".
}

LOCAL flyTo1Button IS gui:AddButton("Fly to 1").
SET flyTo1Button:ONCLICK TO onFlyTo1@.

function onFlyTo2 {
    SET script TO "test_flyto2".
}

LOCAL flyTo2Button IS gui:AddButton("Fly to 2").
SET flyTo2Button:ONCLICK TO onFlyTo2@.

function onLand {
    SET script TO "test_land".
}

LOCAL landButton IS gui:AddButton("Land").
SET landButton:ONCLICK TO onLand@.

function onDeorbit {
    SET script TO "test_deorbit".
}

LOCAL deorbitButton IS gui:AddButton("Deorbit").
SET deorbitButton:ONCLICK TO onDeorbit@.

function onDump {
    SET script TO "test_dump".
}

LOCAL dumpButton IS gui:AddButton("Dump").
SET dumpButton:ONCLICK TO onDump@.

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

until false {
    SET script TO "".

    gui:Show().

    wait until script <> "".

    gui:Hide().

    CLEARVECDRAWS().
    CLEARSCREEN.

    print "Run " + script.

    runpath(script).
}
