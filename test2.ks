RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/core/lib_warp").
RUNONCEPATH("/vac2/lib").
RUNONCEPATH("/rendezvous/dock").
RUNONCEPATH("/plane/lib").

//rendezvousDock().
for p in ship:partsTagged("") {
    if p:modules:contains("ModuleParachute") {
        local m is p:getModule("ModuleParachute").
        print p.
        print m:allEventNames().
//        print m:allActopmNames().
    }
}

//planeDisarmsChutes().
planeSwitchAtmo().