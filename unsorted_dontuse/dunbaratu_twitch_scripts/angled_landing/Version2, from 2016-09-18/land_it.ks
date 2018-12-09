run once lib_land.

parameter safety_margin is 5.

local first_aim is true.

set burn_now to false.
sas off.
lock steering to srfretrograde.
gear on.

local lasParts is ship:partstagged("landing laser").
local hasLas is false.
local lasMod is 0.
if lasParts:length > 0 {
set lasMod to lasParts[0]:getmodule("LaserDistModule").
set hasLas to true.
lasMod:setfield("Enabled", true).
lasMod:setfield("Visible", true).
}

local prev_time is time:seconds.
local deltaT is 0.1.

until burn_now {

set result to sim_land_spot(
ship:body:mu,
ship:body:position,
ship:availablethrust,
345,
ship:mass,
ship:velocity:surface,
0.5,
false).

set pos to result["pos"].
if has_safe_distance(pos, deltaT) {
set theColor to green.
} else {
set theColor to red.
set burn_now to true.
}

if not burn_now
wait 0.
  
set deltaT to time:seconds - prev_time.
set prev_time to time:seconds.
}
lock throttle to 1.
wait until verticalspeed > -2.0.
set descendPID to pidloop(0.08,0.002,0.02,0,1).
lock throttle to descendPID:update(time:seconds, verticalspeed+descentSpeed()).
lock steering to retro_or_up().
wait until status="LANDED" or status="SPLASHED".
brakes on.
unlock steering.
sas on.
unlock throttle.
set vd1 to 0.
print "Waiting until motion has stopped to turn off SAS.".
wait until ship:velocity:surface:mag < 0.1. 
print "Turning off SAS.".
sas off.
lights on.

if hasLas {
lasMod:setfield("Enabled", false).
lasMod:setfield("Visible", false).
}




function descentSpeed {

local twr is ship:availablethrust / (ship:mass * ship:body:mu / (ship:body:radius+ship:altitude)^2).
local up_accel is (twr-1)/ship:mass.
print "eraseme: TWR="+twr.
return (alt:radar - safety_margin)*up_accel/5.
}




function retro_or_up {
if ship:verticalspeed > -0.2
return lookdirup(ship:up:vector, ship:facing:topVector).
else
return lookdirup(srfretrograde:vector, ship:facing:topvector).
}



function has_safe_distance {
parameter pos, deltaT.

local safe is false.
local use_fallback is true.
local compare_dist is 0.
local test_dist is 0.
local label_prefix is "".

if   hasLas
and
abs(steeringmanager:angleerror) < 1

and
warp = 0
{
aim_laser_at(lasMod, pos).
if first_aim {
wait 0.
wait 0.
set first_aim to false.
}
local dist is lasMod:getfield("distance").
if dist >= 0 {
set use_fallback to false.
set compare_dist to dist - (safety_margin+ship:velocity:surface:mag*deltaT*3.5).
set test_dist to pos:mag.
set label_prefix to "Margin (laser measured): ".
}
}
if use_fallback {
local groundPos to ship:body:geopositionof(pos):position.
set test_dist to (safety_margin+abs(verticalspeed)*deltaT*3.5).
set compare_dist to vdot(pos-groundPos,ship:up:vector).
set label_prefix to "Margin (terrain database guess): ".
}
if test_dist < compare_dist {
set safe to true.
set vd1 to vecdraw(v(0,0,0),pos, green, label_prefix + round(compare_dist-test_dist,1)+"m", 1, true).
} else {
set vd1 to 0.
}

return safe.
}

