
wait until ship:unpacked.
// Only run boot when launching, not when reloading vessel already
// in space:
if ship:periapsis < 100 and ship:body = Kerbin and (status = "LANDED" or status = "PRELAUNCH") {

  hudtext( "Unpacked. Now loading launch software.", 2, 2, 45, green, true).
  switch to 1.
  copy lib_launch from 0.
  copy launch from 0.

  set core:bootfilename to "".
  run launch( 90, 80000).
  lock steering to north.
  wait 15.
  unlock steering.
  panels on.
  print "launch done.".
}
