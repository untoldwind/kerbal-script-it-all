// events are preferred because there are no restrictions
function partsDoEvent {
	parameter module.
	parameter event.
	parameter tag is "".
	
	set event to "^"+event+"\b". // match first word
	local success is false.
	local maxStage is -1.
	if tag = "" and (defined stagingMaxStage)
		set maxStage to stagingMaxStage-1. //see lib_staging
	for p in ship:partsTagged(tag) {
		if p:stage >= maxStage and p:modules:contains(module) {
			local m is p:getModule(module).
			for e in m:allEventNames() {
				if e:matchesPattern(event) {
					m:doEvent(e).
					set success to true.
				}
			}
		}
	}
	return success.
}

function partsExtendSolarPanels {
	parameter tag is "".
	return partsDoEvent("ModuleDeployableSolarPanel", "extend", tag).
}

function partsRetractSolarPanels {
	parameter tag is "".
	return partsDoEvent("ModuleDeployableSolarPanel", "retract", tag).
}

function partsExtendAntennas {
	parameter tag is "".
	return partsDoEvent("ModuleDeployableAntenna", "extend", tag).
}

function partsRetractAntennas {
	parameter tag is "".
	return partsDoEvent("ModuleDeployableAntenna", "Retract", tag).
}
