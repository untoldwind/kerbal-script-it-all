RUNONCEPATH("/mainframe/lib").
RUNONCEPATH("/plane/lib").

mainframeEnsure().

IF mission_state = "launch" {
    planeLaunchSSTO(85000).
    mainframeCircularize().

    updateMissionState("inorbit").
}

IF mission_state = "inorbit" {
  LOCAL dockingPort IS 0.

  for port in core:element:dockingPorts {
    if port:state:contains("PreAttached") {
        SET dockingPort TO port.
        break.
    }
  }

  dockingPort:Undock().
  wait 1.
  set KUniverse:ActiveVessel to core:vessel. 
  wait 1.

  updateMissionState("deployed").
}

IF mission_state = "deployed" {
  rcs on.
  lock steering to ship:facing.
  set ship:control:translation to v(0,0,1).
  wait 10.
  set ship:control:translation to v(0,0,0).
  unlock steering.

  updateMissionState("separated").
}

IF mission_state = "separated" {
    planeDeorbit().
    planeAerobrake().
    planeLand().

    updateMissionState("done").
}
