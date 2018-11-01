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
