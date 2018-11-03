// Create manuvering node: Hohmann transfer based on phase angle estimation

RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").

function orbitNodeHoh {
  parameter MaxOrbitsToTransfer is 5.
  parameter MinLeadTime is 30.

  utilRemoveNodes().
  // Compute prograde delta-vee required to achieve Hohmann transfer; < 0 means
  // retrograde burn.
  function hohmannDv {
    parameter r1 is (SHIP:ORBIT:semimajoraxis + SHIP:ORBIT:semiminoraxis) / 2.
    parameter r2 is (TARGET:ORBIT:semimajoraxis + TARGET:ORBIT:semiminoraxis) / 2.

    return SQRT(BODY:MU / r1) * (sqrt( (2*r2) / (r1+r2) ) - 1).
  }

  // Compute time of Hohmann transfer window.
  function hohmannDt {

    local r1 is SHIP:ORBIT:semimajoraxis.
    local r2 is TARGET:ORBIT:semimajoraxis.

    local pt is 0.5 * ((r1+r2) / (2*r2))^1.5.
    local ft is pt - floor(pt).

    // angular distance that target will travel during transfer
    local theta is 360 * ft.
    // necessary phase angle for vessel burn
    local phi is 180 - theta.

    uiDebug("Phi:" + phi).

    // Angles to universal reference direction. (Solar prime)
    set sAng to SHIP:ORBIT:lan + obt:argumentofperiapsis + obt:trueanomaly. 
    set tAng to TARGET:ORBIT:lan + TARGET:ORBIT:argumentofperiapsis + TARGET:ORBIT:trueanomaly. 

    IF TARGET:TYPENAME() = "Body" {
      // Target is a body we do not want to hit, so we advance the target angle a bit
      LOCAL tAngDelta IS 8 * TARGET:RADIUS / CONSTANT:PI / r2 * 360.
      SET tAng TO tAng - tAngDelta.
    }

    local timeToHoH is 0.

    // Target and ship's angular speed.
    local tAngSpd is 360 / TARGET:ORBIT:period.
    local sAngSpd is 360 / SHIP:ORBIT:period.

    // Phase angle rate of change, 
    local phaseAngRoC is tAngSpd - sAngSpd. 

    // Loop conditions variables
    local HasAcceptableTransfer is false.
    local IsStranded is false.
    local tries is 0.
    until HasAcceptableTransfer or IsStranded {

        // Phase angle now.
        set pAng to utilAngleTo360(tAng - sAng).
        uiDebug("pAng: " + pAng).
      
        if r1 < r2 { // Target orbit is higher
          set DeltaAng to utilAngleTo360(pAng - phi).
        }
        else { // Target orbit is lower
          set DeltaAng to utilAngleTo360(phi - pAng).
        }
        set timeToHoH to abs(DeltaAng / phaseAngRoC).
        uiDebug("TTHoh:" + timeToHoH).

        if timeToHoH > SHIP:ORBIT:period * MaxOrbitsToTransfer set IsStranded to true.
        else if timeToHoH > MinLeadTime set HasAcceptableTransfer to true.
        else {
            // Predict values in future
            set tAng to tAng + MinLeadTime * tAngSpd.
            set sAng to sAng + MinLeadTime * sAngSpd.
        }
        set tries to tries + 1.
        if tries > 1000 set IsStranded to true.
        if IsStranded break.
    }
    if IsStranded return "Stranded".
    else return timeToHoH + time:seconds.  
  }

  if body <> target:body {
    uiWarning("Node", "Incompatible orbits").
  }
  if SHIP:ORBIT:eccentricity > 0.01 {
    uiWarning("Node", "Eccentric ship e=" + round(SHIP:ORBIT:eccentricity, 1)).
  }
  if TARGET:ORBIT:eccentricity > 0.01 {
    uiWarning("Node", "Eccentric target e=" +  + round(TARGET:ORBIT:eccentricity, 1)).
  }

  global node_ri is obt:inclination - TARGET:ORBIT:inclination.
  if abs(node_ri) > 0.2 {
    uiWarning("Node", "Bad alignment ri=" + round(node_ri, 1)).
  }

  uiDebug("Hohmann time").
  global node_T is hohmannDt().

  if node_T = "Stranded" {
    uiError("Node", "STRANDED").
  }
  else {
    uiDebug("Hohmann delta V").
    uiDebug("Transfer eta=" + round(node_T - time:seconds, 0)).
    uiDebug("Transfer dv0=" + round(hohmannDv, 1)).

    local r1 is (positionat(ship,node_T)-body:position):mag.
    global node_dv is hohmannDv(r1).
    uiDebug("Transfer dv1=" + round(node_dv, 1) + ", r1=" + round(r1)).

    local nd is node(node_T, 0, 0, node_dv).
    add nd.

    local r2 is (positionat(target,node_T+nd:orbit:period/2)-body:position):mag.
    set node_dv to hohmannDv(r1,r2).
    set nd:prograde to node_dv.
    uiDebug("Transfer dv2=" + round(node_dv, 1) + ", r2=" + round(r2)).
  }
}