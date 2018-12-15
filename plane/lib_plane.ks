FUNCTION planeRadarAltimeter {
    return ship:altitude - ship:geoposition:terrainheight.
}

FUNCTION planeRelVec {
    parameter face.

    if face:ISTYPE("direction") { // Ensure that face is a vector
        set face to face:VECTOR.
    } else {
        set face to face:NORMALIZED.
    }

    LOCAL x TO SHIP:NORTH:VECTOR * face.
    LOCAL y TO VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR) * face.
    LOCAL z TO SHIP:UP:VECTOR * face.

    return V(x, y, z).
}

FUNCTION planeRelAngle {
    parameter face.

    LOCAL relVec TO planeRelVec(face).
    LOCAL yaw TO ARCTAN2(relVec:Y, relVec:X).
    LOCAL pitch TO ARCTAN2(relVec:Z, SQRT(relVec:X * relVec:X + relVec:Y * relVec:Y)).

    return V(yaw, pitch, 0).
}

FUNCTION planeHeadingOf {
    parameter face.

    if face:ISTYPE("direction") { // Ensure that face is a vector
        set face to face:VECTOR.
    } else {
        set face to face:NORMALIZED.
    }

    LOCAL x TO SHIP:NORTH:VECTOR * face.
    LOCAL y TO VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR) * face.

    return ARCTAN2(y, x).
}

GLOBAL debugSteering IS VECDRAW().
GLOBAL debugSteeringTop IS VECDRAW().
GLOBAL debugUp is VECDRAW().
GLOBAL debugFacing IS VECDRAW().
GLOBAL debugFacingTop IS VECDRAW().
GLOBAL debugVelocity IS VECDRAW().
GLOBAL debugTarget IS VECDRAW().

function planeDebugVectors {
    parameter steerDir.
    parameter targetVec IS V(0,0,0).

    SET debugSteering:VEC TO 30 * steerDir:FOREVECTOR.
    SET debugSteering:COLOR TO RGB(1,0,0).
    SET debugSteering:LABEL TO "Steering".
    SET debugSteering:SHOW TO true.

    SET debugSteeringTop:VEC TO 30 * steerDir:TOPVECTOR.
    SET debugSteeringTop:COLOR TO RGB(1,0,0).
    SET debugSteeringTop:LABEL TO "Steering Top".
    SET debugSteeringTop:SHOW TO true.

    SET debugUp:VEC TO 30 * SHIP:UP:FOREVECTOR.
    SET debugUp:COLOR TO RGB(1,1,0).
    SET debugUp:LABEL TO "Up".
    SET debugUp:SHOW TO true.

    SET debugFacing:VEC TO 20 * SHIP:FACING:FOREVECTOR.
    SET debugFacing:COLOR TO RGB(1,1,1).
    SET debugFacing:LABEL TO "Facing".
    SET debugFacing:SHOW TO true.

    SET debugFacingTop:VEC TO 20 * SHIP:FACING:TOPVECTOR.
    SET debugFacingTop:COLOR TO RGB(1,1,1).
    SET debugFacingTop:LABEL TO "Facing Top".
    SET debugFacingTop:SHOW TO true.

    SET debugVelocity:VEC TO 35 * SHIP:VELOCITY:SURFACE:NORMALIZED.
    SET debugVelocity:COLOR TO RGB(0,1,0).
    SET debugVelocity:LABEL TO "Velocity".
    SET debugVelocity:SHOW TO true.

    IF targetVec:MAG > 0 {
        SET debugTarget:VEC TO targetVec.
        SET debugTarget:COLOR TO RGB(0,0,1).
        SET debugTarget:LABEL TO "Target".
        SET debugTarget:SHOW TO true.
    }
}