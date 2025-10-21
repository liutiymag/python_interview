*** Settings ***
Library       String

Resource      ../CommonAPI.robot
Resource      ./landmark.robot
Resource      ./herd.robot
Resource      ./paddock.robot
Resource      ../../Variables/user_ui.robot

*** Variables ***
${USER_UI_URL} =       ${BASE_URL_API}/user/ui

*** Keywords ***
Set Location For User
    [Documentation]     Sets location for user
    [Arguments]         ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    ${zoom} =                    Evaluate             random.uniform(0.1, 20.0)
    ${x_coord} =                 Evaluate             random.uniform(-90, 90)
    ${y_coord} =                 Evaluate             random.uniform(-180, 180)
    ${coordinates} =             Create List          ${y_coord}    ${x_coord}
    ${location} =                Create Dictionary    type=Point    coordinates=${coordinates}
 
    ${user_location} =           Create Dictionary    location=${location}
    ...                                               zoom=${zoom}

    #Set location
    FOR    ${key}    IN    @{kwargs}
        ${user_location}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =   Do API call      PUT     ${USER_UI_URL}/location     params=${params}    json=${user_location}    expected_status=${expected_status}
    RETURN  ${response}

Get User Location
    [Documentation]     Get User location
    [Arguments]         ${farm_id}=${None}    ${expected_status}=200    
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END

    ${response} =       Do API call    GET      ${USER_UI_URL}/location    params=${params}  expected_status=${expected_status}
    RETURN    ${response}

Presetup For Create Folder 
    [Documentation]     Create Herd, Landmark, Paddock 
    [Arguments]         ${farm_id}       
    ${section}          Evaluate       random.choice(${SECTIONS_TYPES})
       
    IF   "${section}" == "HerdFolder"   
        # Create herd with collar
        ${create_herd} =               Create New Herd        farm_id=${farm_id}
        ${herd_list} =                 Create List            ${create_herd.json()}[id]     
        RETURN  ${section}  ${herd_list} 

    ELSE IF  "${section}" == "LandmarkFolder"
        #Create landmark
        ${create_landmark_resp} =      Create New Landmark    farm_id=${farm_id}
        ${landmark_list} =             Create List            ${create_landmark_resp.json()}[id]
        RETURN  ${section}  ${landmark_list} 

    ELSE IF  "${section}" == "PaddockFolder"    
        # Create paddock
        ${create_paddock} =            Create New Paddock     farm_id=${farm_id}
        ${paddock_list} =              Create List            ${create_paddock.json()}[id]
        RETURN  ${section}  ${paddock_list} 
    END
    
Create Folder Within Item
    [Documentation]     Create Folder Within Item
    [Arguments]           ${section}  ${itemIds}    ${farm_id}=${None}  ${expected_status}=204
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END 

    ${folder} =           Create Dictionary       
    ${folder}[id] =       Generate UUID
    ${folder}[name]       Generate Random String  128
	${folder}[children]=  Create list                   
	${folder}[itemIds] =  Set Variable            ${itemIds}
    ${folder}[visible]=   Set Variable            ${TRUE}  
    ${folders_info}=      Create List             ${folder} 
    ${folders}=           Create Dictionary    folders=${folders_info}
    ${response} =       Do API call    PUT      ${USER_UI_URL}/global_state/${section}    params=${params}   json=${folders}  expected_status=${expected_status}
    RETURN    ${response} 
    
Get UI State Folder Exist
    [Documentation]     Create Folder Within Item
    [Arguments]         ${section}    ${farm_id}=${None}  ${expected_status}=200 
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
          ${params} =    Create Dictionary    farmId=${farm_id}
    END  
    ${response} =       Do API call    GET      ${USER_UI_URL}/global_state/${section}    params=${params}   expected_status=${expected_status}
    RETURN    ${response}

Get UI State Folder Not Exist
    [Documentation]     Create Folder Within Item
    [Arguments]         ${section}    ${farm_id}=${None}  ${expected_status}=204 
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
          ${params} =    Create Dictionary    farmId=${farm_id}
    END  
    ${response} =       Do API call    GET      ${USER_UI_URL}/global_state/${section}    params=${params}   expected_status=${expected_status}
    RETURN    ${response}

Set User UI State
    [Documentation]    Set UI state
    [Arguments]        ${section}    ${farm_id}=${None}  ${request_json}=${EMPTY}  ${expected_status}=204
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
          ${params} =    Create Dictionary    farmId=${farm_id}
    END  
    ${response} =       Do API call    PUT      ${USER_UI_URL}/state/${section}    params=${params}   json=${request_json}    expected_status=${expected_status}
    RETURN    ${response}
Get User UI State
    [Documentation]    Get UI state
    [Arguments]        ${section}    ${farm_id}=${None}  ${expected_status}=200
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
          ${params} =    Create Dictionary    farmId=${farm_id}
    END  
    ${response} =       Do API call    GET      ${USER_UI_URL}/state/${section}    params=${params}   expected_status=${expected_status}
    RETURN    ${response}

Set User UI Alert Settings
    [Documentation]    Set for User the UI Alert settings. Return type: response
    [Arguments]      ${alerts_lists}    ${farm_id}=${None}    ${expected_status}=200  
    ${params} =    Set Variable    ${None}  
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    ${body} =        Create Dictionary    types=${alerts_lists}
    ${response} =    Do API Call          PUT    ${USER_UI_URL}/alert    params=${params}    json=${body}   expected_status=${expected_status}
    RETURN    ${response}

Get User UI Alert Settings
    [Documentation]    Get User UI Alert Settings
    [Arguments]      ${farm_id}=${None}    ${expected_status}=200    
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
          ${params} =    Create Dictionary    farmId=${farm_id}
    END  
    ${response} =    Do API Call          GET    ${USER_UI_URL}/alert    params=${params}       expected_status=${expected_status}
    RETURN    ${response}    
