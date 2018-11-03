// Create a change periapsis manuvering node.
//
// Parameters:
//   alt: The desired new periapsis
//   nodetime: Timestamp of the manuvering node (Default: At the apoapsis)

RUNONCEPATH("/orbit/node_alt").

function orbitNodePeri {
    parameter alt.
    parameter nodetime is TIME:SECONDS + ETA:APOAPSIS.

    orbitNodeAlt(alt, nodetime).
}