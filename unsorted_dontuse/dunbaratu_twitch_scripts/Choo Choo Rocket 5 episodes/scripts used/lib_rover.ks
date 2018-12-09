// Given a location, drive there.
// stop when you get there.
function drive_to {
  parameter geopos.
  parameter cruise_spd.

  local steer_pid is PIDLOOP(0.03, 0.0005, 0.01, -1, 1).
  local throttle_pid is PIDLOOP(.5, 0.1, 0.01, -1, 1).


  brakes off.

  until geopos:distance < 50 {
    set ship:control:wheelsteer to steer_pid:update( time:seconds, geopos:bearing ).
    set ship:control:wheelthrottle to
      throttle_pid:update(time:seconds, ship:groundspeed - wanted_speed(geopos, cruise_spd)).
    clearscreen.
    print "position is at bearing " + round(geopos:bearing, 1) + "    ".
    print "spd is " + round(ship:groundspeed, 2) + "    ".
    print "current control:wheelthrottle is " + round(ship:control:wheelthrottle,2).
    print "current control:wheelsteer is " + round(ship:control:wheelsteer,3).
    wait 0.001.
  }
  lock wheelthrottle to 0.
  brakes on.
}

function wanted_speed {
  parameter spot.
  parameter cruise_spd.

  local bear is spot:bearing.
  if bear = 0 {
    return min( spot:distance / 10, cruise_spd).
  } else {
    return min( abs(90/bear), min( spot:distance / 10, cruise_spd)).
  }
}
