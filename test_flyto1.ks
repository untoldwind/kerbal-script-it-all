print "Test flyto1".

RUNONCEPATH("/plane/lib").

planeFlyTo(LATLNG(-3, -70):ALTITUDEPOSITION(5000) - BODY:POSITION, 500).
