RUNONCEPATH("/core/lib_util").

// Cancel most velocity with respect to target. Leave residual speed
function dockMatchVelocity {
  parameter residual.

  set residual to max(0.1, residual). // Minimum residual value allowed.
  set RCSTheresold to 1. // Below this speed will use RCS

  // Don't let unbalanced RCS mess with our velocity
  rcs off.
  sas off.

  local matchStation is 0.
  if target:istype("Part") {
    set matchStation to target:ship.
  } else {
    set matchStation to target.
  }

  local matchAccel is SHIP:availablethrust / SHIP:mass.
  local lock matchVel to (ship:velocity:orbit - matchStation:velocity:orbit).

  if matchVel:mag > residual + RCSTheresold {
    // Point away from relative velocity vector
    local lock steerDir to lookdirup(-matchVel, ship:facing:upvector).
    lock steering to steerDir.
    wait until utilIsShipFacing(steerDir:vector).

    // Cancel velocity
    local v0 is matchVel:mag.
    lock throttle to min(matchVel:mag / matchAccel, 1.0).
    wait 0.1. // Let some time pass so the difference in speed is correcly acounted.
    // Stops the engines if reach near residual speed or if speed starts increasing. (May happens with some cases where the ship is not perfecly aligned with matchVel and residual is very low)
    until (matchVel:mag <= (residual + RCSTheresold)) or (matchVel:mag > v0) {
      set v0 to matchVel:mag.
      wait 0.1. //Assure measurements are made some time apart. 
    }

    lock throttle to 0.
    unlock throttle.
  }
  // Use RCS to cancel remaining dv
  unlock steering.
  //utilRCSCancelVelocity(matchVel@,residual,15).

  unlock matchVel.
}
