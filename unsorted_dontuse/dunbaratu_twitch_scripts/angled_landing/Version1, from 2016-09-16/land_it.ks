run once lib_land.

set burn_now to false.
sas off.
lock steering to srfretrograde.
gear on.
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
  set groundPos to ship:body:geopositionof(pos):position.
  if vdot(pos-groundPos,ship:up:vector) > 5+abs(verticalspeed) {
    set theColor to green.
  } else {
    set theColor to red.
    set burn_now to true.
  }

  set vd1 to vecdraw(v(0,0,0),pos, theColor, "safety margin " + round((pos-groundPos):mag,1)+"m", 1, true).
  if not burn_now
    wait 0.
}

function descentSpeed {
  return 3.0*(alt:radar/10).
}
lock throttle to 1.
wait until verticalspeed > -2.0.
set descendPID to pidloop(0.05,0.002,0.02,0,1).
lock throttle to descendPID:update(time:seconds, verticalspeed+descentSpeed()).
lock steering to retro_or_up().
wait until status="LANDED" or status="SPLASHED".
brakes on.
unlock steering.
sas on.
unlock throttle.
set vd1 to 0.
wait 5.
sas off.

function retro_or_up {
  if ship:verticalspeed > 0.2
    return lookdirup(ship:up:vector, ship:facing:topVector).
  else
    return lookdirup(srfretrograde:vector, ship:facing:topvector).
}
