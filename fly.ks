LOCAL KSPRunwayStartGeo IS LATLNG(-0.0486, -74.715).
LOCAL KSPRunwayEndGeo IS LATLNG(-0.050, -74.4947394).

CLEARVECDRAWS().

SET runway TO VECDRAW(
      KSPRunwayStartGeo:ALTITUDEPOSITION(KSPRunwayStartGeo:TERRAINHEIGHT + 1),
      KSPRunwayEndGeo:ALTITUDEPOSITION(KSPRunwayEndGeo:TERRAINHEIGHT + 1) - KSPRunwayStartGeo:ALTITUDEPOSITION(KSPRunwayStartGeo:TERRAINHEIGHT + 1),
      RGB(1,0,0),
      "See the arrow?",
      1.0,
      TRUE,
      0.2
    ).
