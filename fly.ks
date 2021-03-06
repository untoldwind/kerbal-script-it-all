runoncepath("/core/lib_ui").
runoncepath("/plane/lib_parts").

LOCAL RunwayStart IS LATLNG(-0.0486, -74.715):POSITION - BODY:POSITION.
LOCAL RunwayEnd IS LATLNG(-0.050, -74.4947394):POSITION - BODY:POSITION.
LOCAL RunwayDir IS RunwayEnd - RunwayStart.

CLEARVECDRAWS().

LOCAL atmoEngines IS planeAtmoEngines().
LOCAL vacEngines IS planeVacEngines().

LOCAL tgtHeading IS 90.
LOCAL steerHeading IS 90.
LOCAL steerPitch IS 0.
LOCAL steerRoll IS 0.
LOCK steerDir TO HEADING(steerHeading, steerPitch) + R(0, 0, steerRoll).
LOCAL steerThrottle IS 0.

LOCK STEERING TO steerDir.
LOCK THROTTLE TO steerThrottle.

LOCAL throttlePID TO  PIDLOOP(0.01,0.006,0.016,0,1).
LOCAL hdgPID IS PIDLOOP(0.5, 0.1, 0.8, -15, 15).

LOCK PathDIff TO VXCL(RunwayDir:NORMALIZED, RunwayStart - SHIP:POSITION + BODY:POSITION).

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
  SET steerPitch TO 10.
  return FALSE.
}

UNTIL SHIP:ALTITUDE > 20000 {
  WAIT 0.

  SET steerHeading TO tgtHeading + hdgPID:UPDATE(TIME:SECONDS, PathDIff:Y).

  updateVectors().

  PRINT "PathDiff: " + PathDIff + "                  " at (0, 0).
  PRINT "SteerHeading: " + steerHeading + "              " at (0, 1).
}

UNLOCK STEERING.
UNLOCK THROTTLE.