RUNONCEPATH("/vac2/lib").

SET TARGET TO "Land Target".
LOCAL LandSite IS TARGET:GEOPOSITION.
vacHoverTo(LandSite:LAT, LandSite:LNG, 50).
