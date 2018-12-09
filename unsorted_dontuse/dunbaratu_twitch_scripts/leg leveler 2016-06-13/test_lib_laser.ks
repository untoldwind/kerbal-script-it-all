run once lib_laser.

clearscreen.
print "Toggle ag1 to begin the leveler, or stop it.".
print "Hit ag2 to quit program".

set done to false.
set ag1_changed to false.
set ag1 to false.

on ag2 { set done to true. }
on ag1 {
  set ag1_changed to true.
  return true. // preserve this.
}

lib_laser["leg_level_setup"]("level_").

until done {
  if ag1_changed {
    set ag1_changed to false.
    if ag1 {
      lib_laser["leg_level_start"]().
    } else {
      lib_laser["leg_level_end"]().
    }
    local enabled is "enabled".
    if not ag1 { set enabled to "disabled". }
    print "leveler is now " + enabled + ".           " at (10,15).
  }
  if ag1 {
    wait 0.
    lib_laser["leg_level_update"](5,5).
  }
  if ship:status = "LANDED" or ship:status = "SPLASHED" {
    print "SHIP LANDED, SO DISABLING LEVELER" at (10,15).
    set ag1 to false.
    lib_laser["leg_level_end"]().
  }
  wait 0.
}

print "Done with leveler program".
