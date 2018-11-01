// Create a new change apoapsis manuvering node.
//
// Parameters:
//   alt: The desired new apoapsis
//   nodetime: Timestamp of the manuvering node (Default: At the periapsis)

parameter alt.
parameter nodetime is TIME:SECONDS + ETA:PERIAPSIS.

runpath("/orbit/node_alt", alt, nodetime).

