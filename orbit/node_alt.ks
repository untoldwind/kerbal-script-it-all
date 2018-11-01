// Create a change altitude manuvering node
//
// Parameters:
//   alt: The desired new altitude
//   nodetime: Timestamp of the manuvering node (Default: 2 minutes from now)

parameter alt.
parameter nodetime is time:seconds + 120.

LOCAL mu is BODY:mu.
LOCAL br is BODY:radius.

// present orbit properties
LOCAL vom is SHIP:velocity:ORBIT:MAG.  // current velocity
LOCAL r is br + altitude.  // current radius
LOCAL v1 is VELOCITYAT(ship, nodetime):ORBIT:MAG. // velocity at burn time
LOCAL sma1 is ORBIT:semimajoraxis.

// future orbit properties
LOCAL r2 is br + SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP, nodetime)).
LOCAL sma2 is (alt + br + r2)/2.
LOCAL v2 is SQRT( vom^2 + (mu * (2/r2 - 2/r + 1/sma1 - 1/sma2 ) ) ).

// create node
LOCAL deltav is v2 - v1.

ADD NODE(nodetime, 0, 0, deltav).
