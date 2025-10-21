*** Settings ***
Library       String
Library       JSONLibrary

Resource      ../CommonAPI.robot
Resource      ./user.robot
Resource      ../../Variables/paddock.robot

*** Variables ***
${PADDOCK_URL} =      ${BASE_URL_API}/paddock

*** Keywords ***    
Create New Paddock
    [Arguments]    ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END

    ${SECRET_PROJECT_info} =                          Create Dictionary
    ${SECRET_PROJECT_info}[name] =                    Run Keyword If    ${{'name' in ${kwargs}}}
    ...                                      Set Variable  ${kwargs}[name]  
    ...                                      ELSE  Generate Random String  128

    ${SECRET_PROJECT_info}[type] =                    Run Keyword If    ${{'type' in ${kwargs}}}
    ...                                      Set Variable  ${kwargs}[type]  
    ...                                      ELSE  Evaluate    random.choice(${PADDOCK_TYPES})

    ${SECRET_PROJECT_info}[alert] =                   Run Keyword If    ${{'alert' in ${kwargs}}}
    ...                                      Set Variable  ${kwargs}[alert]  
    ...                                      ELSE  Evaluate    random.choice([${False}, ${True}])

    ${SECRET_PROJECT_info}[location] =                Create Dictionary
    ${SECRET_PROJECT_info}[location][type] =          Run Keyword If    ${{'location' in ${kwargs} and 'type' in ${kwargs}.get('location', dict())}}
    ...                                      Set Variable  ${kwargs}[location][type]
    ...                                      ELSE  Set Variable    Polygon

    ${SECRET_PROJECT_info}[location][coordinates] =   Run Keyword If    ${{'location' in ${kwargs} and 'coordinates' in ${kwargs}.get('location', dict())}}
    ...                                      Set Variable  ${kwargs}[location][coordinates]
    ...                                      ELSE  Generate SECRET_PROJECT Coordinates    ${SECRET_PROJECT_info}[type]

    ${SECRET_PROJECT_info}[shockWidth] =              Run Keyword If    ${{'shockWidth' in ${kwargs}}}
    ...                                      Set Variable  ${kwargs}[shockWidth]  
    ...                                      ELSE  Evaluate    random.randint(0, 300)

    ${SECRET_PROJECT_info}[soundWidth] =              Run Keyword If    ${{'soundWidth' in ${kwargs}}}
    ...                                      Set Variable  ${kwargs}[soundWidth]  
    ...                                      ELSE  Evaluate    random.randint(0, 300)

    ${SECRET_PROJECT_info}[SECRET_PROJECTEdge] =              Run Keyword If    ${{'SECRET_PROJECTEdge' in ${kwargs}}}
    ...                                     Set Variable  ${kwargs}[SECRET_PROJECTEdge]  
    ...                                     ELSE  Generate SECRET_PROJECT Edges    ${SECRET_PROJECT_info}[location]    ${SECRET_PROJECT_info}[type]

    ${response} =      Do API call    POST    ${PADDOCK_URL}    params=${params}    json=${SECRET_PROJECT_info}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created paddock with ID: ${response.json()}[id]
    END
    RETURN    ${response}

Update Paddock By ID
    [Arguments]    ${paddock_id}    &{kwargs}
    ${get_response} =    Get Paddock By ID    ${paddock_id}
    ${paddock_info} =    Set Variable      ${get_response.json()}

    FOR    ${key}    IN    @{kwargs}
        ${paddock_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END

    ${put_response} =    Do API call    PUT    ${PADDOCK_URL}/${paddock_id}    json=${paddock_info}    expected_status=any
    RETURN    ${put_response}

Get Paddock By ID
    [Arguments]    ${paddock_id}    ${expected_status}=200
    ${response} =  Do API call    GET    ${PADDOCK_URL}/${paddock_id}    expected_status=${expected_status}
    RETURN    ${response}

Get Paddocks
    [Arguments]    ${request_params}=${None}
    ${response} =  Do API call    GET    ${PADDOCK_URL}    params=${request_params}    expected_status=any
    RETURN    ${response}

Get Paddocks Activation
    [Arguments]    ${farm_id}    ${expected_status}=200    &{request_params}
    ${request_params}[farmId] =  Set Variable          ${farm_id}
    ${response} =  Do API call    GET    ${BASE_URL_API}/paddockActivation    params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Search Paddock In List By ID
    [Arguments]    ${paddock_id}    ${paddocks_list}
    FOR  ${paddock}    IN    @{paddocks_list}
        IF   "${paddock}[id]" == "${paddock_id}"
            RETURN    ${paddock}
        END
    END
    Fail    Paddock not found in paddocks list. ID: ${paddock_id}

Get Default User FarmId
    [Arguments]    ${username}
    ${user_info} =    Get User By Name    ${username}
    RETURN    ${user_info}[farmId]

Generate SECRET_PROJECT Coordinates
    [Arguments]   ${type}=${None}    ${points_number}=${None}
    IF  '${type}'=='MOVEMENT'
        ${coordinates} =  Generate Rectangle Map Coordinates
        ${coordinates_list} =      Create List  @{coordinates}    ${coordinates}[0]
        ${SECRET_PROJECT_coordinates} =     Create List  ${coordinates_list}
    ELSE
        IF  ${points_number}==${None}
            ${points_number} =  Evaluate  random.randint(3,10)
        END
        ${SECRET_PROJECT_coordinates} =  Generate Polygon Map Coordinates  ${points_number}
    END        
    RETURN    ${SECRET_PROJECT_coordinates}
