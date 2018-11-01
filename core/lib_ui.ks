function uiConsole {
  parameter prefix.
  parameter msg.

  LOCAL logtext is "T+" + round(time:seconds) + " " + prefix + ": " + msg.
  PRINT logtext.

  if logconsole {
    LOG logtext to "log.txt".
    IF HOMECONNECTION:ISCONNECTED {
      COPYPATH("log.txt","0:/logs/"+SHIP:NAME+".txt").
    }
  }
}

function uiWarning {
  parameter prefix.
  parameter msg.

  uiConsole(prefix, msg).
  HUDTEXT(msg, 10, 4, 36, YELLOW, false).
  uiAlarm().
}

function uiError {
  parameter prefix.
  parameter msg.

  uiConsole(prefix, msg).
  HUDTEXT(msg, 10, 4, 36, RED, false).
  uiAlarm().
}

function uiFatal {
  parameter prefix.
  parameter message.

  uiError(prefix, message + " - RESUME CONTROL").
  wait 3.
  reboot.
}

FUNCTION uiAlarm {
    local vAlarm TO GetVoice(0).
    set vAlarm:wave to "TRIANGLE".
    set vAlarm:volume to 0.5.
      vAlarm:PLAY(
          LIST(
              NOTE("A#4", 0.2,  0.25), 
              NOTE("A4",  0.2,  0.25), 
              NOTE("A#4", 0.2,  0.25), 
              NOTE("A4",  0.2,  0.25),
              NOTE("R",   0.2,  0.25),
              NOTE("A#4", 0.2,  0.25), 
              NOTE("A4",  0.2,  0.25), 
              NOTE("A#4", 0.2,  0.25), 
              NOTE("A4",  0.2,  0.25)
          )
      ).
}
