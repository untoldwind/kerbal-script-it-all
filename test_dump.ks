print "Test dump".

RUNONCEPATH("/plane/lib").

print KSCRunwayEnd:HEADING.
print planeRelAngle(KSCRunwayEnd:POSITION).
print planeHeadingOf(KSCRunwayEnd:POSITION).

SET W1 TO LATLNG(-3, -70).

print W1:HEADING.
print planeRelAngle(W1:POSITION).
print planeHeadingOf(W1:POSITION).

SET W2 TO LATLNG(-4, -80).

print W2:HEADING.
print planeRelAngle(W2:POSITION).
print planeHeadingOf(W2:POSITION).

print planeRelAngle(HEADING(110, 10)).
print planeRelAngle(HEADING(120, 30)).