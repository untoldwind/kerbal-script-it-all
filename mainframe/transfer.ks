// Transfer to target

RUNONCEPATH("/core/lib_warp").

function mainframeTransfer {
  LOCAL currentSituation IS ORBIT:TRANSITION.
  until ORBIT:TRANSITION <> currentSituation {
    warpSeconds(ETA:TRANSITION + 1).
  }

  // Deal with collisions and retrograde orbits (sorry this script can't do free return)
  local minperi is (body:atm:height + (body:radius * 0.3)).

  if ship:periapsis < minperi or ship:obt:inclination > 90 {
    SAS off.
    LOCK STEERING TO heading(90,0).
    wait 10.
    LOCK deltaPct TO (ship:periapsis - minperi) / minperi.
    LOCK throttle TO max(1,min(0.1,deltaPct)).
    Wait Until ship:periapsis > minperi.
    LOCK throttle to 0.
    UNLOCK all.
  }
}
