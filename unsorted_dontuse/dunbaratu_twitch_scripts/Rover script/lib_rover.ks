local has_jump_detector is false.
local jump_detector is 0.

// Given a location, drive there.
// stop when you get there.
function drive_to {
  parameter geopos, cruise_spd, proximity_needed is 10, offset_pitch is 0.

  local steer_pid is PIDLOOP(0.015, 0.0005, 0.005, -1, 1).
  local throttle_pid is PIDLOOP(.5, 0.1, 0.01, -1, 1).

  local jump_detectors is ship:ModulesNamed("LaserDistModule").
  for jd in jump_detectors {
    if jd:part:tag = "jump detector" {
      set jump_detector to jd.
      set has_jump_detector to true.
      jump_detector:SETFIELD("Enabled", true).
    }
  }

  brakes off.

  until geo_dist(geopos) < proximity_needed {
    set ship:control:wheelsteer to steer_pid:update( time:seconds, rotated_bearing(geopos, offset_pitch) ).
    local speed_diff is forward_speed(offset_pitch) - wanted_speed(geopos, cruise_spd, offset_pitch).
    set ship:control:wheelthrottle to
      throttle_pid:update(time:seconds, speed_diff).
    if speed_diff > 5 { brakes on.  } else { brakes off. }
    clearscreen.
    print "position is at bearing " + round(rotated_bearing(geopos, offset_pitch), 1) + "    ".
    print "spd is " + round(ship:groundspeed, 2) + "    ".
    print "current control:wheelthrottle is " + round(ship:control:wheelthrottle,2).
    print "current control:wheelsteer is " + round(ship:control:wheelsteer,3).
    print "brakes on? " + brakes + ". ".
    print "forward_speed is " + round(forward_speed(offset_pitch), 3).
    print "wanted_speed is  " + round(wanted_speed(geopos,cruise_spd, offset_pitch),3).
    print "geodist to target is " + round(geo_dist(geopos),2).
    if is_upsidedown(offset_pitch) {
      flip_me(offset_pitch).
      steer_pid:reset().
      throttle_pid:reset().
    }
    wait 0.001.
  }
  set ship:control:wheelthrottle to 0.
  brakes on.
  if has_jump_detector {
    jump_detector:SETFIELD("Enabled", false).
  }
}

function geo_dist {
  parameter geo_spot.

  local ship_geo is ship:body:geopositionof(ship:position).

  return (geo_spot:position - ship_geo:position):mag.
}

function flip_me {
  parameter offset_pitch.
  print "OH NOESSS!!! I'm upside down!!! Flipping over...".
  brakes on.
  local rightleg_mod is ship:partstagged("rightleg")[0]:getmodule("ModuleWheelDeployment").
  local leftleg_mod is ship:partstagged("leftleg")[0]:getmodule("ModuleWheelDeployment").
  local topleg_mod is ship:partstagged("topleg")[0]:getmodule("ModuleWheelDeployment").

  until not is_upsidedown(offset_pitch) {
    local mode is 0.
    if topleg_mod:getfield("state") = "Retracted" { 
      set mode to 0.
    } else {
      set mode to 1.
    }
    
    if mode = 0 and topleg_mod:getfield("state") = "Retracted" { 
      toggle_leg(topleg_mod).
    } else if mode = 1 and topleg_mod:getfield("state") = "Deployed" { 
      toggle_leg(topleg_mod).
    }
    if mode = 1 and leftleg_mod:getfield("state") = "Retracted" { 
      toggle_leg(leftleg_mod).
    } else if mode = 0 and leftleg_mod:getfield("state") = "Deployed" { 
      toggle_leg(leftleg_mod).
    }
    if mode = 1 and rightleg_mod:getfield("state") = "Retracted" { 
      toggle_leg(rightleg_mod).
    } else if mode = 0 and rightleg_mod:getfield("state") = "Deployed" { 
      toggle_leg(rightleg_mod).
    }
    wait 2.
  }
  print "Rightside up now I think.".
  print "waiting 5 seconds to let things settle.".
  wait 5.
  
  if topleg_mod:getfield("state") = "Retracted" { 
    toggle_leg(topleg_mod).
  }
  if leftleg_mod:getfield("state") = "Retracted" { 
    toggle_leg(leftleg_mod).
  }
  if rightleg_mod:getfield("state") = "Retracted" { 
    toggle_leg(rightleg_mod).
  }
  brakes off.
}

function toggle_leg {
  parameter legModule.

  if legModule:hasevent("Retract") {
    legModule:doevent("Retract").
  } else if legModule:hasevent("Extend") {
    legModule:doevent("Extend").
  }
}

function rotated_forevector {
  parameter pitch_rot.
  return angleaxis(pitch_rot, ship:facing:starvector) * ship:facing:forevector.
}
function rotated_topvector {
  parameter pitch_rot.
  return angleaxis(pitch_rot, ship:facing:starvector) * ship:facing:topvector.
}

function rotated_bearing {
  parameter spot, pitch_rot.

  local project_myFore is vxcl(ship:up:vector, rotated_forevector(pitch_rot)).
  local project_spotVec is vxcl(ship:up:vector, spot:position).

  local abs_angle is vang(project_myFore, project_spotVec).
  if vdot( project_spotVec, ship:facing:starvector ) < 0 {
     return abs_angle.
  } else {
     return -abs_angle.
  }
}

function is_upsidedown {
  parameter offset_pitch.
  local topvang is vang( rotated_topvector(offset_pitch), ship:up:vector).
  local starvang is vang( ship:facing:starvector, ship:up:vector).

  local result is topvang > 70 or starvang < 20 or starvang > 160.
  return result.
}

function forward_speed {
  parameter offset_pitch.
  return vdot( ship:velocity:surface, rotated_forevector(offset_pitch)).
}

function wanted_speed {
  parameter spot.
  parameter cruise_spd.
  parameter offset_pitch.

  local bear is rotated_bearing(spot, offset_pitch).
  local return_val is 0.
  if bear = 0 {
    set return_val to min( 0.5 + spot:distance / 10, cruise_spd).
  } else {
    set return_val to min( abs(90/bear), min( 0.5 + spot:distance / 10, cruise_spd)).
  }
  // If there is a jump detector laser, use it.
  if has_jump_detector {
    local dist is jump_detector:GetField("Distance").
    if dist < 0 or dist > 500 {
      set return_val to min(5,return_val). // slow down over a jump unless it was already slower than that.
    }
  }
  return return_val.
}
