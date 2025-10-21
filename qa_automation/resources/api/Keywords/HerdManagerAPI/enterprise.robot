*** Settings ***
Library       String

Resource      ../CommonAPI.robot

*** Variables ***
${ENTERPRISE_URL} =    ${BASE_URL_API}/enterprise

*** Keywords ***
Get Enterprise by ID
    [Arguments]    ${enterprise_id}
    ${response} =      Do API call    GET    ${ENTERPRISE_URL}/${enterprise_id}    expected_status=any
    RETURN    ${response}

Create Enterprise
    [Arguments]    ${expected_status}=200    &{kwargs}
    ${response} =  Create Enterprise Common  ${expected_status}    &{kwargs}
    RETURN    ${response}

Get Enterprises List
    [Arguments]    ${request_params}=${None}
    ${response} =      Do API call    GET    ${ENTERPRISE_URL}    params=${request_params}    expected_status=any
    RETURN    ${response}

Update Enterprise
    [Arguments]    ${id}    &{kwargs}
    ${response} =    Do API call      PUT    ${ENTERPRISE_URL}/${id}      json=${kwargs}    expected_status=any
    RETURN    ${response}
