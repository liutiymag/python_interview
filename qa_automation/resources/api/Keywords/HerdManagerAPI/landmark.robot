*** Settings ***
Library       String

Resource      ../CommonAPI.robot
Resource      ../../Variables/landmark.robot

*** Variables ***
${LANDMARK_URL} =    ${BASE_URL_API}/landmark

*** Keywords ***    
Create New Landmark
    [Arguments]    ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    
    ${landmark_info} =                          Create Dictionary
    ${landmark_info}[name] =                    Run Keyword If    ${{'name' in ${kwargs}}}
    ...                                         Set Variable  ${kwargs}[name]  
    ...                                         ELSE  Generate Random String  128

    ${landmark_info}[showIcon] =                Run Keyword If    ${{'showIcon' in ${kwargs}}}
    ...                                         Set Variable  ${kwargs}[showIcon]  
    ...                                         ELSE  Set Variable    ${False}

    ${landmark_info}[location] =                Create Dictionary
    ${landmark_info}[location][type] =          Run Keyword If    ${{'location' in ${kwargs} and 'type' in ${kwargs}.get('location', dict())}}
    ...                                         Set Variable  ${kwargs}[location][type]
    ...                                         ELSE  Evaluate    random.choice(list(${LANDMARK_LOCATION_TYPES}.keys()))

    ${landmark_info}[location][coordinates] =   Run Keyword If    ${{'location' in ${kwargs} and 'coordinates' in ${kwargs}.get('location', dict())}}
    ...                                         Set Variable  ${kwargs}[location][coordinates]
    ...                                         ELSE  Generate Landmark Coordinates    ${landmark_info}[location][type]

    ${landmark_info}[type] =                    Run Keyword If    ${{'type' in ${kwargs}}}
    ...                                         Set Variable  ${kwargs}[type]  
    ...                                         ELSE  Evaluate    random.choice(list(${LANDMARK_LOCATION_TYPES}[${landmark_info}[location][type]].keys()))    

    ${landmark_info}[color] =                   Run Keyword If    ${{'color' in ${kwargs}}}
    ...                                         Set Variable  ${kwargs}[color]  
    ...                                         ELSE  Set Variable    ${LANDMARK_LOCATION_TYPES}[${landmark_info}[location][type]][${landmark_info}[type]]

    ${response} =      Do API call    POST    ${LANDMARK_URL}    params=${params}    json=${landmark_info}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created landmark with ID: ${response.json()}[id]
    END
    RETURN    ${response}

Get Landmarks
    [Arguments]    ${farm_id}=${None}    ${expected_status}=200
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    
    ${response} =  Do API call    GET    ${LANDMARK_URL}    params=${params}    expected_status=${expected_status}
    RETURN    ${response}

Get Landmark By ID
    [Arguments]    ${landmark_id}    ${expected_status}=200
    ${response} =  Do API call    GET    ${LANDMARK_URL}/${landmark_id}    expected_status=${expected_status}
    RETURN    ${response}

Get Landmark ID By Name
    [Arguments]     ${farm_id}  ${name}
    ${landmarks} =  Get Landmarks    ${farm_id}
    FOR    ${landmark}  IN  @{landmarks.json()}
        IF    '${landmark}[name]'=='${name}'
            RETURN    ${landmark}[id]
        END
    END
    Fail    Landmark not found. Name: ${name}

Update Landmark
    [Arguments]    ${landmark_id}    ${expected_status}=200    &{kwargs}
    ${info_response} =    Get Landmark By ID    landmark_id=${landmark_id}
    # Update landmark
    ${landmark_info} =    Set Variable    ${info_response.json()}
    FOR    ${key}    IN    @{kwargs}
        ${landmark_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =    Do API call    PUT    ${LANDMARK_URL}/${landmark_id}    json=${landmark_info}    expected_status=${expected_status}
    RETURN    ${response}

Batch Update Landmarks Type
    [Arguments]    ${landmark_ids}    ${type}    ${farm_id}=${None}    ${expected_status}=204
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    ${body} =      Create Dictionary          ids=${landmark_ids}    type=${type}
    ${response} =  Do API call     PUT        ${LANDMARK_URL}/batch    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Generate Landmark Coordinates
    [Arguments]   ${landmark_location_type}    ${points_number}=${None}
    ${landmark_coordinates} =      Create List
    IF  '${landmark_location_type}'=='Point'
        ${coordinates} =           Generate Map Coordinates    1
        ${landmark_coordinates} =  Set Variable                ${coordinates}[0]

    ELSE IF  '${landmark_location_type}'=='LineString'
        IF  ${points_number}==${None}
            ${points_number} =     Evaluate                    random.randint(2,7)
        END
        ${landmark_coordinates} =  Generate Map Coordinates    ${points_number}

    ELSE  # Generate Polygon
        IF  ${points_number}==${None}
            ${points_number} =     Evaluate                    random.randint(3,10)
        END
        ${landmark_coordinates} =  Generate Polygon Map Coordinates    ${points_number}
    END
    RETURN  ${landmark_coordinates}
