run once lib_launch.
parameter
  compass is 90,
  orbit_height is 80000,
  second_height is -1,
  second_height_long is -1.

local countdown is 5.
until countdown = 0 {
  hudtext("T minus " + countdown + "s", 2, 2, 45, yellow, true).
  wait 1.
  set countdown to countdown - 1.
}.
hudtext("Launch!", 2, 2, 50, yellow, true).
set ship:control:pilotmainthrottle to 0.

print "Proof I am trying to call launch(). eraseme.".
launch(compass, orbit_height, true, second_height, second_height_long).
