runoncepath("/core/lib_ui").
runoncepath("/plane/lib_parts").

LOCAL KSPRunwayStart IS LATLNG(-0.0486, -74.715):POSITION.
LOCAL KSPRunwayEnd IS LATLNG(-0.050, -74.4947394):POSITION.

CLEARVECDRAWS().

SET runway TO VECDRAW(
      KSPRunwayStart + V(0, 0, 1),
      KSPRunwayEnd - KSPRunwayStart,
      RGB(1,0,0),
      "See the arrow?",
      1.0,
      TRUE,
      0.2
    ).

print 

// LOCAL atmoEngines IS planeAtmoEngines().
// LOCAL vacEngines IS planeVacEngines().

// LOCAL steerHeading IS 90.
// LOCAL steerPitch IS 0.
// LOCAL steerRoll IS 0.
// LOCAL steerThrottle IS 0.

// LOCK STEERING TO HEADING(head, pitch) + R(0, 0, roll).
// LOCK THROTTLE TO steerThrottle.

// planeSwitchAtmo().
// BRAKES OFF.
// SAS OFF.
// RCS OFF.
// LIGHTS ON.
// BAYS OFF.
// INTAKES ON.



// UNLOCK STEERING.
// UNLOCK THROTTLE.