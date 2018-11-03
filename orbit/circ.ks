RUNONCEPATH("/core/lib_util").
RUNONCEPATH("/orbit/exec_node").
RUNONCEPATH("/orbit/node_apo").
RUNONCEPATH("/orbit/node_peri").

function orbitCirc {
    utilRemoveNodes().

    IF ORBIT:transition = "ESCAPE" or ETA:PERIAPSIS < ETA:APOAPSIS {
        orbitNodeApo(ORBIT:PERIAPSIS). 
    } ELSE {
        orbitNodePeri(ORBIT:APOAPSIS).
    }

    orbitExecNode().
}