parameter waypointbasename, spd.


print "Not doing anything until landed!".
// wait until status = "LANDED" and not ship:body:name = "Kerbin".
local control_parts is ship:partstagged("control from me").
if control_parts:length > 0 {
  control_parts[0]:controlfrom().
}


run once lib_rover.

local greeks is list(
  "Alpha",
  "Beta",
  "Gamma",
  "Delta",
  "Epsilon",
  "Zeta",
  "Eta",
  "Theta",
  "Iota",
  "Kappa").

for suffix in greeks {
  local wayname is waypointbasename + " " + suffix.

  if waypoint_exists( wayname ) {
    print "driving to waypoint called " + wayname + ".".
    drive_to(waypoint(wayname):geoposition, spd).
    do_all_experiments().
    wait 1. // needs time to let game spawn next waypoint sometimes.
  } else {
    print "no waypoint called " + wayname + ".  Trying next choice.".
  }
}
function waypoint_exists {
  parameter test_name.

  for wp in allwaypoints() {
    if wp:name = test_name {
      return true.
    }
  }
  return false.
}

function do_all_experiments {
  local all_sci_mods is ship:modulesnamed("ModuleScienceExperiment").
  print "Running all experiments".

  for sci_mod in all_sci_mods {
    if sci_mod:inoperable() or ( sci_mod:hasdata() and not sci_mod:rerunnable() ){
      print "Not taking experiment for " + sci_mod:tostring().
    } else {
      print "eraseme: Tring experiment: " + sci_mod:part:name.
      if sci_mod:hasdata() {
        print "eraseme:   has data, dumping.".
        sci_mod:dump().
        // sci_mod:dump() takes several ticks to finish its effect,
        // so wait until the system says it's done before continuing:
        print "Waiting to dump data from " + sci_mod:part:name.
        wait until not sci_mod:hasdata().
      }
      print "eraseme:   deploying.".
      sci_mod:deploy().
      wait 0.
      wait 0.
    }
  }
}
