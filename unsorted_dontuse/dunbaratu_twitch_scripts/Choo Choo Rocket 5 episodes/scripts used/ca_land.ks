// Perform constant altitude burn style landing.
// Presume that Pe is already set above the landing site.
parameter is_skycrane.
parameter geoc is "none".
parameter lead_angle is 65.

clearscreen.
print " ".
print " ".
print " ".
print " ".
print " ".
print " ".
print " ".
print " ".
print " ".

sas off.
// settings (make into parameters maybe?)
set touch_speed to 1. // m/s to make final touchdown at.
set switch_to_suicide_speed to 10. // m/s to stop CA and switch to suicide.

if geoc:tostring() = "none" {
  print " ".
  print "Waiting until after Apoapsis.".
  wait until
      // On the half of the orbit between Ap and Pe.
      eta:apoapsis > eta:periapsis
    or
      // Ap is never going to happen because orbit is hyperbolic.
      ship:apoapsis < 0
    or
      // Ap is never going to happen because orbit ellipse goes outside SOI.
      ship:apoapsis + ship:body:radius > ship:body:soiradius.

  print "Past Apoapsis.".

  lock steering to (-1)*ship:velocity:surface.
  print "Waiting until Periapsis.".
  wait until eta:periapsis < 60.
  set warp to min(2,warp).
  wait until eta:apoapsis < eta:periapsis.
  set warp to 0.
  print "Just crossed Periapsis.".

} else {

  print "Waiting until pointing toward geocoordinate: " + geoc.
  print " ".
  local dot is -9999.
  until dot > cos(lead_angle) {
    print "Still going away-ish from the target.  dotprod = " + dot.
    set dot to vdot( geoc:position:normalized, ship:velocity:orbit:normalized ).
    wait 1.
  }

  print " ".
  print "Now going mostly toward the target. ".
  print "Waiting until crossing over cosine angle: " + cos(lead_angle).
  local dot is 9999.
  until dot < cos(lead_angle) {
    print "Still going toward-ish the target.  dotprod = " + dot.
    set dot to vdot( geoc:position:normalized, ship:velocity:orbit:normalized ).
    wait 1.
  }
  print "Now going away from it.  Starting the burn.".
}

print " ".
print "Beginning CA burn mode.".
print "----------------------- ".

// High pid gains because it's set so that every 1 m/s or so dropping = 2 degree-ish of deflection.
set aim_up_pid to PIDLOOP(2, 0.5, 0.2, -10, 90). // manages how high above retro vec to aim.
lock throttle to 1.
local prev_ecc to ship:obt:eccentricity.
local new_ecc to ship:obt:eccentricity + 1.
set aim_vec to (-1)*ship:velocity:surface.
lock steering to LookDirUp(aim_vec, ship:north:vector).

// Until going slow, or thrusting is no longer causing it to become more eccentric
// but is instead making it less eccentric (that happens when you pass the point of
// falling straight in and start pushing in the opposite direction):
local done is false.
until done {

  // Seeking a vertical speed of 0 (constant altitude), let the PID controller
  // tell me what angle above retrograde to aim to achieve it:
  set aim_up_angle to aim_up_pid:UPDATE(TIME:SECONDS, ship:verticalspeed).

  // Get the vector pointing horizontally out the side of my motion.
  // This is the axis of rotation to rotate "up" around:
  set side_vec to VCRS(ship:up:vector, ship:velocity:surface).

  // Rotate from retro vector, upward by the angle the PID controller said:
  set aim_vec to ANGLEAXIS(aim_up_angle,side_vec) * ((-1)*ship:velocity:surface).

  print "aim above retrograde by " + round(aim_up_angle,1) + " deg   " at (5,0).

  // crude staging check:
  if ship:availablethrust = 0 { stage. }
  set prev_ecc to new_ecc.
  wait 0.001.
  set new_ecc to ship:obt:eccentricity.
  if ship:velocity:surface:mag < switch_to_suicide_speed {
    set done to true.
    print "Finished because speed < " + switch_to_suicide_speed.
//  } else if (prev_ecc > new_ecc and ship:obt:periapsis < 0) {
//    set done to true.
//    print "Finished because eccentricity started decreasing again.".
  }
}
lock throttle to 0.
wait 0.0001. // Make sure the lock throttle to 0 happens before moving on.

function bottom_dist_from_CoM {
  local biggest is 0.
  local aft_unit is (-1)*ship:facing:forevector. // unit vec in aft direction.
  for p in ship:parts {
    local aft_dist is vdot(p:position, aft_unit). // distance in terms of aft-ness.
    if aft_dist > biggest {
      set  biggest to aft_dist.
    }
  }
  return biggest.
}

print "                                       " at (5,0).

gear off. gear on. // be sure to measure distance AFTER gear is deployed.
// wait 3 seconds to deploy gear, unless super close to the ground then don't wait:
wait min(3,alt:radar*3).

set aftmost to bottom_dist_from_CoM().
print "Distance (ish) to bottom from CoM = " + round(aftmost,1) + "m".

print " ".
print "Suicide drop mode.".
print "----------------- ".
print " ".

set safety_dist to bottom_dist_from_CoM() + 5. // meters to aim suicide burn above ground.
print "Suicide saftey margin above ground = " + round(safety_dist,1) + "m".

// Return either retrograde or just plain up if dangerously close to the vertical speed
// where retrograde flips over.
function steerfunc {
  if ship:verticalspeed < -2 {
    return LookDirUp((-1)*ship:velocity:surface, ship:north:vector).
  } else {
    return LookDirUp(ship:up:vector, ship:north:vector).
  }
}
lock steering to steerfunc().


set rad to ship:body:radius.
set mu to ship:body:mu.
set startmass to ship:mass.
lock grav to (mu/(rad+ship:altitude)^2).
lock surf_grav to (mu/(rad+(ship:altitude-alt:radar))^2).
lock leftoverThrust to (ship:availablethrust*0.97) - ((surf_grav+grav)/2)*ship:mass.
lock stop_dist to ship:velocity:surface:mag^2 / (2*(max(0.001,leftoverThrust)/ship:mass)).

until alt:radar < (stop_dist+safety_dist) {
  print "suicide burn in " + round(alt:radar - (stop_dist+safety_dist), 0) + "m.   " at (5,4).
  // crude staging check:
  if ship:availablethrust = 0 { stage. }
  wait 0.01.
}
print "Suicide burning.".

// Start using correct proper local gravity calculation again:
lock leftoverThrust to ship:availablethrust - grav*ship:mass.

// fudge_ratio is a bit above or below 1.0 depending on if there's
// too little, or too much room left to land:
lock fudge_ratio to ((stop_dist+safety_dist)/alt:radar)*1.2.

// Throttle near 1.0 during suicde burn, but slightly reduce it
// as fuel goes away, such that it will maintain a constant
// acelleration despite mass reduction:
lock throttle to (ship:mass/startmass) * fudge_ratio.

until ship:verticalspeed > -touch_speed {
  print "predict dist = " + round(stop_dist+safety_dist,1) + "m   " at (5,1).
  print "actual  dist = " + round(alt:radar,1) + "m   " at (5,2).
  print "cur Throttle = " + round(100*throttle,2) + "%   " at (5,3).
  if ship:availablethrust = 0 { stage. }
  wait 0.01.
}.

print " ".
print "Descending to touchdown.".
print "------------------------".

set descend_pid to PIDLoop(0.1, 0.01, 0.05, 0, 1).
wait 0.001.
// Should automatically re-run PID_seek again and again like in a loop:
lock throttle to descend_pid:UPDATE( TIME:SECONDS, ship:verticalspeed + 2).

wait until ship:status = "LANDED" or ship:status = "SPLASHED".
set touch_speed to ship:velocity:surface:mag.
print "TOUCHDOWN at Speed of " + round(touch_speed,2) + " m/s".
print ship:status.
if is_skycrane {
  lock steering to up+r(0,10,0).
  lock throttle to 1.
  wait 0.0001.
  stage.
  print "Skycrane staged".
}
unlock steering.
unlock throttle.
sas on.
brakes on.
print "Waiting 10 seconds before turning SAS off".
wait 10.
sas off.
