LOCAL modules IS List().
LOCAL mission IS "mission4".

function bootConsole {
  parameter msg.

  print "T+" + round(time:seconds) + " boot: " + msg.
}

CLEARSCREEN.
bootConsole("kOS " + core:version).
bootConsole(round(core:volume:freespace/1024, 1) + "/" + round(core:volume:capacity/1024) + " kB free").
WAIT 1.

bootConsole("Attemping to connect to KSC...").

IF SHIP:STATUS = "PRELAUNCH" {
    brakes on. // Useful for planes

    runpath("0:/compile", modules, mission).
    runpath("0:/launch_ui", mission).
} ELSE IF HOMECONNECTION:ISCONNECTED {
    // Potentially run an update script
} ELSE {
    // Not sure what to do here
}
