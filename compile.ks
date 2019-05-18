parameter modules.
parameter mission is "".

function compileConsole {
  parameter msg.

  print "T+" + round(time:seconds) + " compile: " + msg.
}

function compileModule {
  parameter module.

  SET path TO "0:/" + module + "/".
  SET targetPath TO "1:/" + module + "/".

  compileConsole("Compile module: " + module).

  CD(path).
  LIST FILES IN fls.
  FOR f in fls {
    IF f:NAME:ENDSWITH(".ks") {
        compileConsole("Compiling... " + path + f:NAME).
        COMPILE path + f:NAME TO targetPath + f:NAME + "m".
    }
  }
  CD("0:/").
}

function compileScripts {
  SET path TO "0:/scripts/".
  SET targetPath TO "1:/scripts/".

  compileConsole("Compile scripts").

  CD(path).
  LIST FILES IN fls.
  FOR f in fls {
    IF f:NAME:ENDSWITH(".ks") {
        compileConsole("Compiling... " + path + f:NAME).
        COMPILE path + f:NAME TO targetPath + f:NAME + "m".
    }
  }
  CD("0:/").
}

SWITCH TO ARCHIVE.

FOR module in modules {
    compileModule(module).
}
if mission <> "" {
  compileConsole("Compiling... 0:/missions/" + mission + ".ks").
  COMPILE "0:/missions/" + mission + ".ks" TO "1:/missions/" + mission + ".ksm".

  COMPILE "0:/mission_ui.ks" TO "1:/mission_ui.ksm".
} else {
  compileScripts().
  COMPILE "0:/manual_ui.ks" TO "1:/manual_ui.ksm".
}

compileConsole("All files updated.").
compileConsole(round(core:volume:freespace/1024, 1) + "/" + round(core:volume:capacity/1024) + " kB free").

SWITCH TO CORE:VOLUME.
