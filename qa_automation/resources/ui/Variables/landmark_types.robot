*** Variables ***
&{TYPE_FEED} =              button=sh-id=landmark-create-panel-item-feed
...                         name=Feed
&{TYPE_CORRAL} =            button=sh-id=landmark-create-panel-item-corral
...                         name=Corral/Yards
&{TYPE_STRUCTURE} =         button=sh-id=landmark-create-panel-item-structure
...                         name=Structure
&{TYPE_GATE} =              button=sh-id=landmark-create-panel-item-gate
...                         name=Gate
&{TYPE_PUMP} =              button=sh-id=landmark-create-panel-item-pump
...                         name=Water Point
&{TYPE_GATEWAY} =           button=sh-id=landmark-create-panel-item-gateway
...                         name=Gateway
&{TYPE_WING} =              button=sh-id=landmark-create-panel-item-wing
...                         name=Fence Wing
&{TYPE_TRAIL} =             button=sh-id=landmark-create-panel-item-trail
...                         name=Trail
&{TYPE_ROAD} =              button=sh-id=landmark-create-panel-item-road
...                         name=Road
&{TYPE_RIVER} =             button=sh-id=landmark-create-panel-item-river
...                         name=River/Stream
&{TYPE_WATER} =             button=sh-id=landmark-create-panel-item-water
...                         name=Water Area
&{TYPE_BURN} =              button=sh-id=landmark-create-panel-item-burn
...                         name=Burn
&{TYPE_AREA} =              button=sh-id=landmark-create-panel-item-area
...                         name=Area

@{POINT_LANDMARKS_UI} =    ${TYPE_FEED}    ${TYPE_CORRAL}    ${TYPE_STRUCTURE}    ${TYPE_GATE}    ${TYPE_PUMP}    ${TYPE_GATEWAY}
@{LINE_LANDMARKS_UI} =     ${TYPE_WING}    ${TYPE_TRAIL}     ${TYPE_RIVER}        ${TYPE_ROAD}
@{AREA_LANDMARKS_UI} =     ${TYPE_WATER}   ${TYPE_BURN}      ${TYPE_AREA}