// This file is distributed under the terms of the MIT license, (c) the KSLib team

@LAZYGLOBAL off.

function PID_init {
  parameter
    Kp, // gain of position
    Ki, // gain of integral
    Kd, // gain of derivative
    cMin, // min legal value of controlled thing.
    cMax. // max legal value of controlled thing.

  local SeekP is 0. // desired value for P (will get set later).
  local P is 0.     // phenomenon P being affected.
  local I is 0.     // crude approximation of Integral of P.
  local D is 0.     // crude approximation of Derivative of P.
  local oldT is -1. // (old time) start value flags the fact that it hasn't been calculated
  local oldInput is 0. // previous return value of PID controller.

  // Because we don't have proper user structures in kOS (yet?)
  // I'll store the PID tracking values in a list like so:
  //
  local PID_array is list(Kp, Ki, Kd, SeekP, P, I, D, oldT, oldInput, cMin, cMax).

  return PID_array.
}.

function PID_seek {
  parameter
    PID_array, // array built with PID_init.
    seekVal,   // value we want.
    curVal.    // value we currently have.

  // Using LIST() as a poor-man's struct.

  local Kp   is PID_array[0].
  local Ki   is PID_array[1].
  local Kd   is PID_array[2].
  local oldS is PID_array[3]. 
  local oldP is PID_array[4].
  local oldI is PID_array[5].
  local oldD is PID_array[6].
  local oldT is PID_array[7]. // Old Time
  local oldInput is PID_array[8]. // prev return value, just in case we have to do nothing and return it again.
  local cMin is PID_array[9].
  local cMax is PID_array[10].

  local P is seekVal - curVal.
  local D is oldD. // default if we do no work this time.
  local I is oldI. // default if we do no work this time.
  local newInput is oldInput. // default if we do no work this time.

  local t is time:seconds.
  local dT is t - oldT.

  if oldT < 0 {
    // I have never been called yet - so don't trust any
    // of the settings yet.
  } else {
    if dT = 0 { // Do nothing if no physics tick has passed from prev call to now.
      set newInput to oldInput.
    } else {
      set D to (P - oldP)/dT. // crude fake derivative of P
      local onlyPD is Kp*P + Kd*D.
      // Only do integral term when it won't push input outside the range:
      if (oldI < 0 or onlyPD < cMax) and (oldI > 0 or onlyPD > cMin) {
        set I to oldI + P*dT. // crude fake integral of P
      }
      set newInput to onlyPD + Ki*I.
    }.
  }.

  // clamp input to allowed range.
  set newInput to max(cMin,min(cMax,newInput)).

  // remember old values for next time.
  set PID_array[3] to seekVal.
  set PID_array[4] to P.
  set PID_array[5] to I.
  set PID_array[6] to D.
  set PID_array[7] to t.
  set PID_array[8] to newInput.

  return newInput.
}.
