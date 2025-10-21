*** Settings ***
Library       String

Resource      ../CommonAPI.robot

*** Variables ***
${CATTLE_URL} =  ${BASE_URL_API}/cattle

*** Keywords ***
Create New Cattle
    [Arguments]    ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    ${cattle_info} =            Create Dictionary
    ${cattle_info}[earTag] =    Generate Random String    128

    FOR    ${key}    IN    @{kwargs}
        ${cattle_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END

    # Create cattle
    ${response} =   Do API call      POST     ${CATTLE_URL}     params=${params}    json=${cattle_info}    expected_status=${expected_status}
    IF  ${{${response.status_code} == 200}}
        Log To Console  Created cattle with id "${response.json()}[id]"
    END
    RETURN  ${response}

Get Cattle By ID
    [Arguments]    ${cattle_id}    ${expected_status}=200
    ${response} =  Do API call     GET      ${CATTLE_URL}/${cattle_id}    expected_status=${expected_status}
    RETURN         ${response}

Get Cattles
    [Arguments]    ${expected_status}=200    &{request_params}
    ${response} =  Do API call    GET    ${CATTLE_URL}    params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Update Cattle
    [Arguments]    ${cattle_id}    ${expected_status}=200    &{kwargs}
    ${info_response} =    Get Cattle By ID    cattle_id=${cattle_id}
    # Update cattle
    ${cattle_info} =    Set Variable    ${info_response.json()}
    FOR    ${key}    IN    @{kwargs}
        ${cattle_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =    Do API call    PUT    ${CATTLE_URL}/${cattle_id}    json=${cattle_info}    expected_status=${expected_status}
    RETURN    ${response}
