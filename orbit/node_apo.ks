// Create a new change apoapsis manuvering node.
//
// Parameters:
//   alt: The desired new apoapsis
//   nodetime: Timestamp of the manuvering node (Default: At the periapsis)

RUNONCEPATH("/orbit/node_alt").

function orbitNodeApo {
    parameter alt.
    parameter nodetime is TIME:SECONDS + ETA:PERIAPSIS.

    orbitNodeAlt(alt, nodetime).
}
