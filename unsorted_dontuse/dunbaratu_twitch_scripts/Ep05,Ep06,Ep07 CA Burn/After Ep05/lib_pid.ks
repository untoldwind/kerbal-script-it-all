

@LAZYGLOBAL off.

function PID_init {
parameter
Kp,
Ki,
Kd,
cMin,
cMax.

local SeekP is 0.
local P is 0.
local I is 0.
local D is 0.
local oldT is -1.
local oldInput is 0.




local PID_array is list(Kp, Ki, Kd, SeekP, P, I, D, oldT, oldInput, cMin, cMax).

return PID_array.
}.

function PID_seek {
parameter
PID_array,
seekVal,
curVal.



local Kp   is PID_array[0].
local Ki   is PID_array[1].
local Kd   is PID_array[2].
local oldS is PID_array[3]. 
local oldP is PID_array[4].
local oldI is PID_array[5].
local oldD is PID_array[6].
local oldT is PID_array[7].
local oldInput is PID_array[8].
local cMin is PID_array[9].
local cMax is PID_array[10].

local P is seekVal - curVal.
local D is oldD.
local I is oldI.
local newInput is oldInput.

local t is time:seconds.
local dT is t - oldT.

if oldT < 0 {


} else {
if dT = 0 {
set newInput to oldInput.
} else {
set D to (P - oldP)/dT.
local onlyPD is Kp*P + Kd*D.

if (oldI < 0 or onlyPD < cMax) and (oldI > 0 or onlyPD > cMin) {
set I to oldI + P*dT.
}
set newInput to onlyPD + Ki*I.
}.
}.


set newInput to max(cMin,min(cMax,newInput)).


set PID_array[3] to seekVal.
set PID_array[4] to P.
set PID_array[5] to I.
set PID_array[6] to D.
set PID_array[7] to t.
set PID_array[8] to newInput.

return newInput.
}.
