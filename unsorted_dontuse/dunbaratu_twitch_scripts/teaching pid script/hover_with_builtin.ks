local want_alt is 500.
local my_throt is 1.
sas on.
print "I'm not controlling the steering.".
print "I'll let you do that.".

local prev_err is 0.
local prev_time is time:seconds.
local err_integ is 0.

wait 0.
lock throttle to my_throt.
set throtpid to pidloop(0.02, 0.0002, 0.5, 0, 1).
until false {
  set my_throt to throtpid:update(time:seconds, (altitude - want_alt)).
  wait 0.
}
