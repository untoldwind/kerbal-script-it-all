RUNONCEPATH("/core/lib_util").

RUNONCEPATH("/orbit/node_alt").

    utilRemoveNodes().

    LOCAL ta to 53.


    local dt is utilDtTrue(ta).
    local t1 is time:seconds + dt.

    orbitNodeAlt(1492914, t1).
