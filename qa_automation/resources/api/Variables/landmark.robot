*** Variables ***
&{LANDMARK_LOCATION_TYPES} =    Point=&{POINT_LANDMARKS}
...                             LineString=&{LINE_LANDMARKS}
...                             Polygon=&{AREA_LANDMARKS}

&{POINT_LANDMARKS} =            CORRAL=\#000000
...                             FEED=\#000000
...                             GATE=\#000000
...                             GATEWAY=\#000000
...                             PUMP=\#000000
...                             STRUCTURE=\#000000

&{LINE_LANDMARKS} =             RIVER=\#00ffff
...                             ROAD=\#ffffff
...                             TRAIL=\#ffff00
...                             WING=\#ffffff

&{AREA_LANDMARKS} =             FENCE=\#ffffff
...                             AREA=\#000000
...                             WATER=\#00ffff
...                             BURN=\#ff0000