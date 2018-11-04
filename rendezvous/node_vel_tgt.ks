// Create manouver node: Match velocity at closest approach

RUNONCEPATH("/core/lib_ui").
RUNONCEPATH("/core/lib_util").

function rendezvousNodeVelTgt {
    // Figure out some basics
    local T is utilClosestApproach(SHIP, TARGET).
    local Vship is VELOCITYAT(SHIP, T):orbit.
    local Vtgt is VELOCITYAT(TARGET, T):orbit.
    local Pship is POSITIONAT(SHIP, T) - BODY:POSITION.
    local dv is Vtgt - Vship.

    // project dv onto the radial/normal/prograde direction vectors to convert it
    // from (X,Y,Z) into burn parameters. Estimate orbital directions by looking
    // at position and velocity of ship at T.
    local r is Pship:normalized.
    local p is Vship:normalized.
    local n is vcrs(r, p):normalized.
    local sr is vdot(dv, r).
    local sn is vdot(dv, n).
    local sp is vdot(dv, p).

    // figure out the ship's braking time
    local accel is SHIP:availablethrust / SHIP:mass.
    local dt is dv:mag / accel.

    // Time the burn so that we end thrusting just as we reach the point of closest
    // approach. Assumes the burn program will perform half of its burn before
    // T, half afterward
    add node(T-(dt/2), sr, sn, sp).
}