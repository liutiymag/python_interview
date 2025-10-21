*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${FARM_URL} =    ${BASE_URL_API}/farm

*** Keywords ***
Create New Farm
    [Arguments]    ${enterprise_id}=${None}    ${expected_status}=200    &{kwargs}
    ${response} =  Create Farm Common    ${enterprise_id}    ${expected_status}    &{kwargs}
    RETURN    ${response}

Get Farms
    [Arguments]    ${request_params}=${None}    ${expected_status}=200
    ${response} =  Do API call    GET    ${FARM_URL}    params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Search Farm In List By ID
    [Arguments]    ${farm_id}    ${farms_list}
    FOR  ${farm}    IN    @{farms_list}
        IF   "${farm}[id]" == "${farm_id}"
            RETURN    ${farm}
        END
    END
    Fail    Farm not found in farms list. ID: ${farm_id} 

Get Farm By ID
    [Arguments]    ${farm_id}    ${expected_status}=200
    ${response} =  Do API call    GET    ${FARM_URL}/${farm_id}    expected_status=${expected_status}
    RETURN    ${response}

Get Farm By Application ID
    [Arguments]    ${application_id}    ${expected_status}=200
    ${response} =  Do API call    GET    ${FARM_URL}/applicationId/${application_id}    expected_status=${expected_status}
    RETURN    ${response}

Update Farm By ID
    [Arguments]    ${farm_id}    ${expected_status}=200    &{kwargs}
    ${get_response} =    Get Farm By ID    ${farm_id}
    ${farm_info} =       Set Variable      ${get_response.json()}

    FOR    ${key}    IN    @{kwargs}
        ${farm_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END

    ${put_response} =    Do API call    PUT    ${FARM_URL}/${farm_id}    json=${farm_info}    expected_status=${expected_status}
    RETURN    ${put_response}

Get Farm Transport ID By Farm ID
    [Arguments]    ${farm_id}
    ${farm_response} =    Get Farm By ID       ${farm_id}
    ${farm_trasportId} =  Set Variable         ${farm_response.json()}[transportId]
    RETURN    ${farm_trasportId}
