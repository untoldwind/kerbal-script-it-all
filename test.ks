RUNONCEPATH("/atmo/lib").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/plane/lib").


//atmoLaunchAscent().
//planeLaunchSSTO().
//mainframeCircularize().
//vacLand(0, -60).
//vacHoverTo(0, -60, 100).

for p in SHIP:PARTS {
    if p:NAME:CONTAINS("SkyCrane") {
        LOCAL m IS p:GETMODULE("ModuleAnimateGeneric").
        if m:HASEVENT("extend engines") {
            m:DOEVENT("extend engines").
        }
    }
}
