LOCAL modules IS List("core", "orbit").
LOCAL mission IS "mission9".

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
    bootConsole("At launch site...").

    brakes on. // Useful for planes

    runpath("0:/compile", modules, mission).
} ELSE IF HOMECONNECTION:ISCONNECTED {
    bootConsole("Connected, performing update ...").
    runpath("0:/compile", modules, mission).
} 

runpath("/mission_ui", mission).
