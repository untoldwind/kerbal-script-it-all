print "Test flyto2".

RUNONCEPATH("/plane/lib").

planeFlyTo(LATLNG(-4, -80):ALTITUDEPOSITION(10000) - BODY:POSITION, 500).
