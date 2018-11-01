RUNONCEPATH("/core/lib_util").

utilRemoveNodes().
IF ORBIT:transition = "ESCAPE" or ETA:PERIAPSIS < ETA:APOAPSIS {
    RUNPATH("/orbit/node_apo", ORBIT:PERIAPSIS). 
} ELSE {
    RUNPATH("/orbit/node_peri", ORBIT:APOAPSIS).
}

RUNPATH("/orbit/exec_node").
