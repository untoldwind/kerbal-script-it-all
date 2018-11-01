// Create a change periapsis manuvering node.
//
// Parameters:
//   alt: The desired new periapsis
//   nodetime: Timestamp of the manuvering node (Default: At the apoapsis)

parameter alt.
parameter nodetime is TIME:SECONDS + ETA:APOAPSIS.

RUNPATH("/orbit/node_alt", alt, nodetime).
