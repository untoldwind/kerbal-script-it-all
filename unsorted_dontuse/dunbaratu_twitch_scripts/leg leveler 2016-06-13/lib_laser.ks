// Libraries to be used with laser dist.

// set mod1 to ship:partstagged("leg1")[0]:getmodule("MuMechToggle").
// mod1:DOACTION("move +",true).  // start moving.
// mod1:DOACTION("move +",false).  // stop moving.

// set lasmod1 to ship:partstagged("laser1")[0]:getmodule("LaserDistModule).
// print lasmod1:getfield("Distance").
// print lasmod1:getfield("Enabled").
// lasmod1:setfield("Enabled", true).
// lasmod1:setfield("Enabled", false).


@lazyglobal off.
// make externlly visible hooks to the functions:

global lib_laser is lexicon().
  
{  // Give myself a local scope for the file

  set lib_laser["leg_level_setup"]  to leg_level_setup@.
  set lib_laser["leg_level_start"]  to leg_level_start@.
  set lib_laser["leg_level_update"] to leg_level_update@.
  set lib_laser["leg_level_end"]    to leg_level_end@.
  set lib_laser["normal_setup"]     to normal_setup@.
  set lib_laser["get_normal"]       to get_normal@.

  local slidermods is list().
  local level_lasers is list().
  local slope_lasers is list().
  
  // Tell the library what the list of legs are you wish to operate on.
  function leg_level_setup {
    parameter prefixtag. // tag name to look for for all the sliders and lasers

    set slidermods to list().
    set level_lasers to list().
    // Guaranteed that the same parts walk algorithm being
    // used for both these loops means the parts will
    // be populated in parallel to each other (i.e.
    // level_lasers[i] goes with slidermods[i]):
    for m in ship:modulesnamed("MuMechToggle") {
      if m:part:tag:startswith(prefixtag) {
        slidermods:add(m).
      }
    }
    for m in ship:modulesnamed("LaserDistModule") {
      if m:part:tag:startswith(prefixtag) {
        level_lasers:add(m).
      }
    }
  }
  function leg_level_start {
    for las in level_lasers { laser_toggle(las, true). }
  }

  // Call this over and over in an update loop to move the legs as
  // needed after they were set up with leg_level_setup
  function leg_level_update {
    parameter disp_col is -1, disp_row is 0.

    local dists is get_dists(level_lasers).
    local avg_dist is 0.
    for dist in dists {
      set avg_dist to avg_dist + dist.
    }
    if dists:length > 0 {
      set avg_dist to avg_dist / dists:length.
    }
    local null_zone is 0.05. // null meters where not to move the sliders.

    if disp_col >= 0 {
      print "Avg Dist = " + round(avg_dist,2) + "m   " at (disp_col, disp_row).
    }

    for i in range(0, dists:length) {
      if disp_col >= 0 {
        print "leg " + i + " error = " + round(dists[i] - avg_dist,2) + "m   " at (disp_col, disp_row+i).
      }
      // If the slider's own distance measure is below average, move
      // one way, if it's above average, move the other way.
      if dists[i] > avg_dist + null_zone  {
        // Weirdly, this doesn't work if you do these two lines
        // in the opposite order (move+ before move-). No idea
        // why - have to ask IR people.
        slidermods[i]:doaction("move -", false).
        slidermods[i]:doaction("move +", true).
        if disp_col >= 0 {
          print "moving +" at (disp_col+30, disp_row+i).
        }
      } else if dists[i] < avg_dist - null_zone {
        // Weirdly, this doesn't work if you do these two lines
        // in the opposite order (move+ before move-). No idea
        // why - have to ask IR people.
        slidermods[i]:doaction("move +", false).
        slidermods[i]:doaction("move -", true).
        if disp_col >= 0 {
          print "moving -" at (disp_col+30, disp_row+i).
        }
      } else {
        // stop all motions:
        slidermods[i]:doaction("move -", false).
        slidermods[i]:doaction("move +", false).
        if disp_col >= 0 {
          print "        " at (disp_col+30, disp_row+i).
        }
      }
    }
  }

  function leg_level_end {
    for slider in slidermods {
      slider:doaction("move -", false).
      slider:doaction("move +", false).
    }
    for las in level_lasers { laser_toggle(las, false). }
  }

  function laser_toggle {
    parameter lasmod, newVal.
    lasmod:setfield("Enabled", newVal).
  }

  // Query all the distances at once so we don't do it
  // multiple times per loop iteration:
  function get_dists {
    parameter las_list.
    local return_val is list().
    for las in las_list {
      return_val:add( las:getfield("Distance") ).
    }
    return return_val.
  }

  // Query all the lasers at once to get their XYZ emitter
  // positions.
  function get_positions {
    parameter las_list.
    local return_val is list().
    for las in las_list {
      return_val:add( las:part:position ). // laser tip position.
    }
    return return_val.
  }

  // Query all the lasers at once to get their XYZ unit vectors.
  function get_vectors {
    parameter las_list.
    local return_val is list().
    for las in las_list {
      return_val:add( las:part:facing:vector ). // laser tip position.
    }
    return return_val.
  }

  // Give it a prefix tag name of the laser parts that contain the
  // 3 parallel laser emitters.
  function normal_setup {
    parameter prefixtag. // tag name to look for for all the slope lasers

    set slope_lasers to list().
    for m in ship:modulesnamed("LaserDistModule") {
      if m:part:tag:startswith(prefixtag) {
        slope_lasers:add(m).
        m:setfield("Enabled",true).
        m:setfield("Visible",true).
      }
    }
  }

  // Must call normal_setup first to define which 3 lasers you're using.
  // Returns 2 things in a list: the normal vector and the position
  // at which it starts (where the terrain hit was).
  // Returns a pair of zero magnitude vectors if there was no hit.
  function get_normal {
    parameter up_unit is ship:up:vector. // unit vector for which way is up

    // step 1: get the laser distances:
    local dists is get_dists(slope_lasers).
    local positions is get_positions(slope_lasers).
    local unit_vectors is get_vectors(slope_lasers).

    if dists:length < 3 {
      PRINT "ERROR in get_normal!.  Need 3 lasers.".
      return LIST(V(0,0,0),V(0,0,0)).
    }

    if dists[0] < 0 {
      return LIST(V(0,0,0),V(0,0,0)).
    }

    local hit_positions is list().
    for i in range(0, 3) {
      hit_positions:add( positions[i] + dists[i]*unit_vectors[i] ).
    }

    local vec1 is (hit_positions[1] - hit_positions[0]).
    local vec2 is (hit_positions[2] - hit_positions[0]).
    local norm is vcrs(vec1, vec2):normalized.

    // reverse the normal vector if it's pointing down into the planet:
    if vdot(norm,up_unit) < 0 {
      set norm to -norm.
    }

    return LIST(norm, hit_positions[0]).
  }


}
