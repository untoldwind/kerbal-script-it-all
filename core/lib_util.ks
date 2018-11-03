// Check if ship is facing a specific direction or vector. Useful for a wait until while turning.
// 
// Returns true if:
// Ship is facing the FaceVec whiting a tolerance of maxDeviationDegrees and
// with a Angular velocity less than maxAngularVelocity.
// 
// Paramters:
//   Direction or Vector to Check
//   Maximum deviation in degrees (default: 8)
//   Maximum angular velocity (default: 0.01) 
function utilIsShipFacing { 
  parameter face.
  parameter maxDeviationDegrees is 8.
  parameter maxAngularVelocity is 0.01.

  if face:ISTYPE("direction") { // Ensure that face is a vector
      set face to face:VECTOR.
  }

  return face:NORMALIZED * SHIP:FACING:FOREVECTOR:NORMALIZED >= COS(maxDeviationDegrees) and
         SHIP:ANGULARVEL:MAG < maxAngularVelocity. 
}

// remove all nodes and wait one tick if there was any
function utilRemoveNodes {
	IF not HASNODE return.
	FOR n IN ALLNODES REMOVE n.
	WAIT 0.
}

// convert any angle to range [0, 360)
function utilAngleTo360 {
	parameter a.
	set a to mod(a, 360).
	if a < 0 set a to a + 360.
	return a.
}

// convert from true to mean anomaly
function utilMeanFromTrue {
	parameter a.
	parameter obt is ORBIT.
	set e to obt:eccentricity.
	if e < 0.001 return a. //circular, no need for conversion
	if e >= 1 { print "ERROR: meanFromTrue("+round(a,2)+") with e=" + round(e,5). return a. }
	set a to a*0.5.
	set a to 2*arctan2(sqrt(1-e)*sin(a),sqrt(1+e)*cos(a)).
//	https://en.wikipedia.org/wiki/Eccentric_anomaly
//	https://en.wikipedia.org/wiki/Mean_anomaly
	return a - e * sin(a) * 180/constant:pi.
}

// eta to true anomaly (angle from periapsis in the direction of movement)
// note: this is the ultimate ETA function which is in KSP API known as GetDTforTrueAnomaly
function utilDtTrue {
	parameter a.
	parameter obt is ORBIT.
	return utilAngleTo360(utilMeanFromTrue(a) - utilMeanFromTrue(obt:trueAnomaly)) / 360 * obt:period.
}
