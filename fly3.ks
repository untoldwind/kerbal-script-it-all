runoncepath("/core/lib_ui").
runoncepath("/plane/lib_parts").

LOCAL RunwayStart IS LATLNG(-0.0486, -74.715):POSITION - BODY:POSITION.
LOCAL RunwayEnd IS LATLNG(-0.050, -74.4947394):POSITION - BODY:POSITION.
LOCAL RunwayDir IS RunwayEnd - RunwayStart.

CLEARVECDRAWS().

LOCAL atmoEngines IS planeAtmoEngines().
LOCAL vacEngines IS planeVacEngines().
LOCK TurnRadius TO 500 + SHIP:VELOCITY:SURFACE:MAG * 50.
LOCK PathDIff TO VXCL(RunwayDir:NORMALIZED, RunwayStart - SHIP:POSITION + BODY:POSITION).

function calcYawDIff {
    IF PathDIff:Y < -TurnRadius * 0.25 {
        return -40.
    }
    IF PathDIff:Y > TurnRadius * 0.25 {
        return 40.
    }
    IF PathDIff:Y < -1 {
        return -ARCCOS((TurnRadius + PathDIff:Y) / TurnRadius).
    } ELSE IF PathDIff:Y > 1 {
        return ARCCOS((TurnRadius - PathDIff:Y) / TurnRadius).
    }
    return 0.
}

LOCAL tgtVertical TO 0.
LOCAL tgtHorizontal TO 200.
LOCK UPVec TO -BODY:POSITION:NORMALIZED.
LOCK yawDiff TO calcYawDIff().
LOCK tgtVelocity TO (RunwayDir:NORMALIZED + V(0, TAN(yawDiff), 0)) * tgtHorizontal + UPVec * tgtVertical.
LOCAL steerRoll IS 0.
LOCK steerDir TO LOOKDIRUP(tgtVelocity:NORMALIZED, UPVec).
LOCAL steerThrottle IS 0.

LOCK STEERING TO steerDir.
LOCK THROTTLE TO steerThrottle.

SET runway TO VECDRAW(
      RunwayStart + V(0, 0, 1) + BODY:POSITION,
      RunwayDir,
      RGB(1,0,0),
      "Runway",
      1.0,
      TRUE,
      0.2
    ).
SET steerDraw TO VECDRAW(
  V(0,0,0),
  30 * steerDir:FOREVECTOR,
  RGB(1,0,0),
  "Steering",
  1.0,
  TRUE,
  0.2
).
SET diffDraw TO VECDRAW(
  SHIP:FACING:FOREVECTOR * 15,
  PathDIff,
  RGB(0,1,0),
  "Diff",
  1.0,
  TRUE,
  0.2
).


function updateVectors {
  SET runway:START TO RunwayStart + V(0, 0, 1) + BODY:POSITION.
  SET runway:VEC TO RunwayDir.

  SET steerDraw:START TO V(0,0,0).
  SET steerDraw:VEC TO 30 * steerDir:FOREVECTOR.

  SET diffDraw:START TO SHIP:FACING:FOREVECTOR * 15.
  SET diffDraw:VEC TO PathDIff.
}

planeSwitchAtmo().
BRAKES OFF.
SAS OFF.
RCS OFF.
LIGHTS ON.
BAYS OFF.
INTAKES ON.

SET steerThrottle TO 1.

WHEN SHIP:AIRSPEED > 90 THEN {
  SET tgtVertical TO 20.
  return FALSE.
}

UNTIL SHIP:ALTITUDE > 20000 {
  WAIT 0.

  updateVectors().

  PRINT "PathDiff: " + PathDIff + "                  " at (0, 0).
  PRINT "yawDiff: " + yawDiff + "                  " at (0, 1).
}

UNLOCK STEERING.
UNLOCK THROTTLE.