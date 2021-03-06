runoncepath("/core/lib_parts").

function planeMMEngineClosedCycle {
    for p in ship:parts {
        if p:modules:contains("MultiModeEngine") {
            local m is p:getModule("MultiModeEngine").
            if m:HasField("mode") and m:GetField("mode"):Contains("Air") {
                for Event in m:allEventNames() {
                    if Event:contains("toggle") m:DoEvent(Event).
                }
            }
        }
    }
}

function planeMultiModeEngines {
    LOCAL result is LIST().

    for p in ship:parts {
        if p:modules:contains("MultiModeEngine") {
            result:ADD(p).
        }
    }
    return result.
}

function planeSwitchAtmo {
    for p in SHIP:PARTSTAGGED("vac") {
        IF p:TYPENAME = "Engine" {
            p:SHUTDOWN.
        }
    }
    for p in SHIP:PARTSTAGGED("atmo") {
        IF p:TYPENAME = "Engine" {
            p:ACTIVATE.
            if p:modules:contains("MultiModeEngine") {
                local m is p:getModule("MultiModeEngine").
                if m:HasField("mode") and m:GetField("mode"):Contains("Closed") {
                    for Event in m:allEventNames() {
                        if Event:contains("toggle") m:DoEvent(Event).
                    }
                }
            }
        }
    }
}

function planeSwitchVac {
    for p in SHIP:PARTSTAGGED("vac") {
        IF p:TYPENAME = "Engine" {
            p:ACTIVATE.
        }
    }
    for p in SHIP:PARTSTAGGED("atmo") {
        IF p:TYPENAME = "Engine" {
            p:SHUTDOWN.
        }
    }
}

function planeDisarmsChutes {
    return partsDoEvent("ModuleParachute", "disarm").
}
