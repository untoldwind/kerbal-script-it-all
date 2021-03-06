function countdown {
  parameter count.
  from { local i is count. } until i = 0 step { set i to i - 1. } do {
    hudtext( "T minus " + i + "s" , 1, 1, 25, white, true).
    wait 1.
  }
}

function launch {
  parameter dest_compass. // not exactly right when not 90.
  parameter first_dest_ap. // first destination apoapsis.
  parameter do_circ is true.
  parameter second_dest_ap is -1. // second destination apoapsis.
  parameter second_dest_long is -1. // second destination longitude.

  if second_dest_ap < 0 { set second_dest_ap to first_dest_ap. }

  print "PROOF I AM INSIDE LAUNCH. eraseme.".


  // For all atmo launches with fins it helps to teach it that the fins help
  // torque, which it fails to realize:

  lock steering to heading(dest_compass, 90 - 90*(altitude/60000)^(2/5)).
  lock throttle to 1.
   
  // set staging_on to false to effectively remove this trigger:
  global staging_on is true.
  when true then {
    if staging_on {
      preserve.
    }
    list engines in englist.
    local flameout is false.
    for eng in englist { if eng:flameout { set flameout to true. } }
    if flameout or maxthrust = 0 {
      stage.
      steeringmanager:resetpids().
    }
  }



  wait until ship:apoapsis > first_dest_ap.

  print "Apoapsis now " + first_dest_ap + ".".
  print "Going into low thrust to just maintain Ap.".
  lock throttle to (first_dest_ap - ship:apoapsis) / 5000.

  wait until ship:altitude > 70000.

  // put controls back now that we're out of atmo:
  set steeringmanager:pitchtorquefactor to 1.
  set steeringmanager:yawtorquefactor to 1.

  print "Coasting to Ap.".
  lock throttle to 0.
  lock steering to heading(dest_compass, 0).

  wait until eta:apoapsis < 10.

  if do_circ {
    circularize().
  } else {
    print "Circularization not requested.".
  }

  if second_dest_long >= 0 {
    lock steering to prograde.
    print "Waiting for second destination burn start longitude.".
    until abs(ship:longitude - second_dest_long) < 1 {
      print "current long = " + round(ship:longitude,3) + ", desired long = " + round(second_dest_long,3) + "    " at (0,0).
      wait 0.001.
    }
    print "Now starting second destination burn.".
    lock throttle to 0.01 + (second_dest_ap - ship:apoapsis) / 5000.
    print "Now waiting for apoapsis to reach " + second_dest_ap.
    wait until ship:apoapsis >= second_dest_ap.
    print "Now re-circularizing at the new apoapsis...".
    circularize().
  }


  set staging_on to false.
  wait 0.01. // make sure there's one run through the trigger to unpreserve it.
}

function east_for {
  parameter ves.

  return vcrs(ves:up:vector, ves:north:vector).
}
// Return eta:apoapsis but with times behind you
// rendered as negative numbers in the past:
function eta_ap_with_neg {
  local ret_val is eta:apoapsis.
  if ret_val > ship:obt:period / 2 {
    set ret_val to ret_val - ship:obt:period.
  }
  return ret_val.
}

function compass_of_vel {
  local pointing is ship:velocity:orbit.
  local east is east_for(ship).

  local trig_x is vdot(ship:north:vector, pointing).
  local trig_y is vdot(east, pointing).

  local result is arctan2(trig_y, trig_x).

  if result < 0 { 
    return 360 + result.
  } else {
    return result.
  }
}

function circularize {
  print "Circularizing.".
  lock steering to heading(compass_of_vel(), -(eta_ap_with_neg()/3)).
  print "..Waiting for steering to finish locking in place.".
  wait until
    abs(steeringmanager:yawerror) < 2 and
    abs(steeringmanager:pitcherror) < 2 and
    abs(steeringmanager:rollerror) < 2.
  print "..Steering locked.  Now throttling.".

  lock throttle to 0.02 + (30*ship:obt:eccentricity).

  wait until ship:obt:trueanomaly < 90 or ship:obt:trueanomaly > 270.

  print "Done Circularlizing.".

  unlock steering.
  unlock throttle.
}
