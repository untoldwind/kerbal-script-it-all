parameter apoapsis IS 90000.

RUNONCEPATH("/atmo/launch_ascent").
RUNONCEPATH("/mainframe/lib").

mainframeEnsure().

SET STEERINGMANAGER:YAWTS TO 4.
SET STEERINGMANAGER:PITCHTS TO 4.

LIGHTS ON.
PRINT "Launch sequence".
atmoLaunchAscent(apoapsis, 90).


mainframeCircularize().
