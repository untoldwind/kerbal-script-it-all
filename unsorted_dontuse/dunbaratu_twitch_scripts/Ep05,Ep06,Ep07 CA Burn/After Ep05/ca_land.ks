

parameter is_skycrane.

clearscreen.
print " ".
print " ".
print " ".
if CONFIG:IPU < 400 {
print "Increasing CONFIG:IPU to 400.  This script needs it.".
set CONFIG:IPU to 400.
}

run lib_pid.
sas off.

set touch_speed to 1.
set switch_to_suicide_speed to 2.

print " ".
print "Waiting until after Apoapsis.".
wait until

eta:apoapsis > eta:periapsis
or

ship:apoapsis < 0
or

ship:apoapsis + ship:body:radius > ship:body:soiradius.

print "Past Apoapsis.".
lock steering to (-1)*ship:velocity:surface.
print "Waiting until Periapsis.".
wait until eta:periapsis < 60.
set warp to min(2,warp).
wait until eta:apoapsis < eta:periapsis.
set warp to 0.
print "Just crossed Periapsis.".

print " ".
print "Beginning CA burn mode.".
print "----------------------- ".


set aim_up_pid to PID_init(2, 0.5, 0.2, -10, 90).
lock throttle to 1.
set orig_vel to ship:velocity:surface.
set aim_vec to (-1)*orig_vel.
lock steering to aim_vec.


until ship:velocity:surface:mag < switch_to_suicide_speed or vdot(ship:velocity:surface, orig_vel) < 0 {



set aim_up_angle to PID_seek(aim_up_pid, 0, ship:verticalspeed).



set side_vec to VCRS(ship:up:vector, ship:velocity:surface).


set aim_vec to ANGLEAXIS(aim_up_angle,side_vec) * ((-1)*ship:velocity:surface).

print "aim above retrograde by " + round(aim_up_angle,1) + " deg   " at (5,0).


if ship:availablethrust = 0 { stage. }
}
lock throttle to 0.

function bottom_dist_from_CoM {
local biggest is 0.
local aft_unit is (-1)*ship:facing:forevector.
for p in ship:parts {
local aft_dist is vdot(p:position, aft_unit).
if aft_dist > biggest {
set  biggest to aft_dist.
}
}
return biggest.
}

gear off. gear on.

wait min(3,alt:radar*3).

set aftmost to bottom_dist_from_CoM().
print "Distance (ish) to bottom from CoM = " + round(aftmost,1) + "m".

print " ".
print "Suicide drop mode.".
print "----------------- ".
print " ".

set safety_dist to bottom_dist_from_CoM() + 5.
print "Suicide saftey margin above ground = " + round(safety_dist,1) + "m".



function steerfunc {
if ship:verticalspeed < -1 {
return (-1)*ship:velocity:surface.
} else {
return ship:up:vector.
}
}
lock steering to steerfunc.


set rad to ship:body:radius.
set mu to ship:body:mu.
lock grav to (mu/(rad+ship:altitude)^2).
lock leftoverThrust to ship:availablethrust - (grav*ship:mass).
lock stop_dist to ship:velocity:surface:mag^2 / (2*(max(0.001,leftoverThrust)/ship:mass)).

set tStamp to 0.

until alt:radar < (stop_dist+safety_dist) {
if time:seconds > tStamp + 2 {
print "suicide burn in " + round(alt:radar - (stop_dist+safety_dist), 0) + "m.".
set tStamp to time:seconds.
}

if ship:availablethrust = 0 { stage. }
}
lock throttle to 1.
print "Suicide burning.".
wait until ship:verticalspeed > -touch_speed.

print " ".
print "Descending to touchdown.".
print "------------------------".

set descend_pid to PID_init(0.05, 0.01, 0.01, 0, 1).

lock throttle to PID_seek(descend_pid, -touch_speed, ship:verticalspeed).

wait until ship:status = "LANDED" or ship:status = "SPLASHED".
set touch_speed to ship:velocity:surface:mag.
print "TOUCHDOWN at Speed of " + round(touch_speed,2) + " m/s".
print ship:status.
if is_skycrane {
lock steering to up+r(0,10,0).
lock throttle to 1.
wait 0.1.
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
