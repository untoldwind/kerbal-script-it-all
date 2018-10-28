parameter modules.
parameter mission.

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

SWITCH TO ARCHIVE.

FOR module in modules {
    compileModule(module).
}
compileModule("missions/" + mission).

compileConsole("All files updated.").

SWITCH TO CORE:VOLUME.
