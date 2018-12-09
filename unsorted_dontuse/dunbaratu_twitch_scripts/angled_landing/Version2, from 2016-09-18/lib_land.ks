global draws is LIST().
















function sim_land_spot {
parameter
GM,
b_pos,
t_max,
isp,
m_init,
v_init,
t_delta,
do_draws is false.

local pos is V(0,0,0).
local t is 0.
local vel is v_init.
local prev_vel is v_init*2.
local prev_a_vec is v(0,0,0).
local m is m_init.





until false {
local up_vec is (pos - b_pos).
local up_unit is up_vec:NORMALIZED.

local reversed is (VDOT(vel, prev_vel) < 0).
if reversed {
break.
}

local r_square is up_vec:SQRMAGNITUDE.
local g is GM/r_square.
local eng_a_vec is t_max*(- vel:normalized) / m.
local a_vec is eng_a_vec - up_unit*g.

set prev_vel to vel.
set prev_a_vec to a_vec.
local avg_a_vec is 0.5*(a_vec+prev_a_vec). 
set vel to vel + avg_a_vec*t_delta.
local avg_vel is 0.5*(vel+prev_vel).
local prev_pos is pos.
set pos to pos + avg_vel*t_delta.
set m to m - (t_max / (9.802*isp)*t_delta).
if m <= 0 { break. }
set t to t + t_delta.

if do_draws {
local tmp_vec is vecdraw(prev_pos, (pos-prev_pos), green, "", 1, true).
draws:add(tmp_vec).
}
}


return Lex(
"pos", pos,
"vel", vel,
"seconds", t,
"mass", m,
"draws", draws
).
}






function aim_laser_at {
parameter
lasMod,
aimVec.

local lasPartFacing is lasMod:part:facing.
local xAxis is lasPartFacing:starvector.
local yAxis is lasPartFacing:topvector.

local aimUnit is aimVec:normalized.

local x is vdot( aimUnit, xAxis).
local y is vdot( aimUnit, yAxis).

local hAngle is arcsin(x).
local vAngle is arcsin(y).








lasMod:setfield("Bend X", - hAngle).
lasMod:setfield("Bend Y", - vAngle).
}
