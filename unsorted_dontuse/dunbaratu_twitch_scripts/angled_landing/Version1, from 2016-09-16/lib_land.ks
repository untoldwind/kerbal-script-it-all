global draws is LIST(). // has to be global because of scoping bugs in vecdraw.

// Run a math simulation of a retro landing thrust that locks to
// retro direction at full throttle the whole time.  Result is a
// Lexicon of some stats about when and where such a thrust would
// reach zero velocity.
//
// Warning: This runs a loop that will likely take several update
// ticks to finish if you want an accurate answer (i.e. if you set
// t_delta to a small number).  If you want it to finish faster,
// set t_delta bigger and you'll get a less accurate answer, but
// get it faster.
//
// This presumes a constant use of the same engine stage (no staging
// partway through).
//
// Returned lexicon: (see comment at bottom of this function).
function sim_land_spot {
  parameter
    GM,      // Gravatational Parameter for the current gravitational body
    b_pos,   // body position vector relative to start position of V(0,0,0).
    t_max,   // thrust you'd get at max throttle (i.e. ship:availablethrust).
    isp,     // ISP of engine(s) that will be performing the burn.
    m_init,  // initial mass of the ship at start of burn.
    v_init,  // initial velocity vector at start position of burn.
    t_delta, // seconds per timestep in the simulation loop.
    do_draws is false.

  local pos is V(0,0,0). // current new position relative to start pos.
  local t is 0. // elapsed time since burn start.
  local vel is v_init. // current new velocity.  Goal is for this to zero out.
  local prev_vel is v_init*2. // force `reverse` flag not to trigger the first time.
  local prev_a_vec is v(0,0,0).
  local m is m_init. // current mass (m_init minus spent fuel).


  // (if the sim loop starts with the velocity *already* ascending, then it doesn't
  // start checking for ascending until after it has started descending at least
  // once during the sim loop.)

  until false { // will break explicitly down below.
    local up_vec is (pos - b_pos).             // vector up from center of body to cur position.
    local up_unit is up_vec:NORMALIZED.

    local reversed is (VDOT(vel, prev_vel) < 0).
    if reversed {
      break.
    }

    local r_square is up_vec:SQRMAGNITUDE.
    local g is GM/r_square.                           // grav accel, as scalar.
    local eng_a_vec is t_max*(- vel:normalized) / m.  // engine accel, as vector.
    local a_vec is eng_a_vec - up_unit*g.             // total accel, as vector.

    set prev_vel to vel.
    set prev_a_vec to a_vec.
    local avg_a_vec is 0.5*(a_vec+prev_a_vec). 
    set vel to vel + avg_a_vec*t_delta.             // new velocity = old vel + accel*deltaT
    local avg_vel is 0.5*(vel+prev_vel).
    local prev_pos is pos.
    set pos to pos + avg_vel*t_delta.               // new pos = old pos + velocity*deltaT.
    set m to m - (t_max / (9.802*isp)*t_delta). // new mass = old mass minus fuel we just spent.
    if m <= 0 { break. } // Ship is not allowed to be composed of anti-matter.
    set t to t + t_delta.

    if do_draws {
      local tmp_vec is vecdraw(prev_pos, (pos-prev_pos), green, "", 1, true).
      draws:add(tmp_vec).
    }
  }


  return Lex(
    "pos", pos,    // position where it stops relative to a start position of v(0,0,0)
    "vel", vel,    // velocity at the moment it ends
    "seconds", t,  // how many seconds will it take to stop.
    "mass", m,     // what will be the new mass after the burn due to spent fuel.  if <=0, then it aborts early.
    "draws", draws // vecdraws to display.
    ).
}
