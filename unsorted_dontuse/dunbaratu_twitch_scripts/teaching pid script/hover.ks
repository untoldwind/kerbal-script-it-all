local want_alt is 500.
local my_throt is 1.
local control_min is 0.
local control_max is 1.
local proportion is 0.02.            // "Kp"  coefficient of proportion of error.
local integ_proportion is 0.000002.  // "Ki"  coefficient of integral of error.
local deriv_proportion is 0.5.       // "Kd"  coefficient of derivative of error.
sas on.
print "I'm not controlling the steering.".
print "I'll let you do that.".

local prev_err is 0.
local prev_time is time:seconds.
local err_integ is 0.

wait 0.
lock throttle to my_throt.
until ag10 {
  set deltaT to time:seconds - prev_time.
  set err to (want_alt - altitude).
  set err_diff to err - prev_err.
  set err_deriv to err_diff / deltaT.
  if my_throt > control_min and my_throt < control_max {
    set err_integ to err_integ + (err / deltaT).
  }

  set my_throt to proportion*err + integ_proportion*err_integ + deriv_proportion*err_deriv.

  print_block.
  set prev_err to err.
  set prev_time to time:seconds.
  wait 0.
}

function print_block {
  clearscreen.
  print "      err = " + round(err,1) + " * " + proportion + " = " + round(err*proportion,2).
  print "err_deriv = " + round(err_deriv,1) + " * " + deriv_proportion + " = " + round(err_deriv*deriv_proportion,2).
  print "err_integ = " + round(err_integ,1) + " * " + integ_proportion + " = " + round(err_integ*integ_proportion,2).
  print " my_throt = " + round(my_throt,3).
}
