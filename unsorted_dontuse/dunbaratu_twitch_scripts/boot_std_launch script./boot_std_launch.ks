wait until ship:unpacked.
// Only run boot when launching, not when reloading vessel already
// in space:
if ship:periapsis < 100 {

  hudtext( "Unpacked. Now loading launch software.", 2, 2, 45, green, true).
  switch to 1.
  copy launch from 0.
  copy lib_launch from 0.
  copy lib_hohmann from 0.

  run launch.
  lock steering to north.
  wait 15.
  unlock steering.
  panels on.
  print "boot_std_launch done.".
}
