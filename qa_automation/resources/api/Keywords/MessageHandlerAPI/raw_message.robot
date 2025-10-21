*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${RAW_MESSAGE_URL} =    ${MESSAGE_HANDLER_URL_API}/message-handler/v1/message

*** Keywords ***
Send deviceInfo Message
    [Arguments]      ${collarId}    ${reliable}    ${expected_status}=204
    ${params} =      Create Dictionary             reliable=${reliable}
    ${response} =    Do API call    POST           ${RAW_MESSAGE_URL}/${collarId}/deviceInfo    params=${params}    expected_status=${expected_status}    is_SECRET_PROJECT_user=${True}
    RETURN    ${response}

Retrieve List Of Messages
    [Arguments]      ${expected_status}=200    &{kwargs}
    ${response} =    Do API call    POST       ${RAW_MESSAGE_URL}    json=${kwargs}    expected_status=${expected_status}    is_SECRET_PROJECT_user=${True}
    RETURN    ${response}

Send setCrmConfig Message
    [Arguments]    ${collar_id}    ${expected_status}=204    &{kwargs}
    ${response} =  Do API call    POST    ${RAW_MESSAGE_URL}/${collar_id}/setCrmConfig    json=${kwargs}    expected_status=${expected_status}    is_SECRET_PROJECT_user=${True}
    RETURN    ${response}

Get Tracking Config By Collar ID
    [Documentation]    Send getTrackingConfig message. Return type: response.
    [Arguments]        ${collar_id}        ${reliable}    ${expected_status}=204
    ${params} =        Create Dictionary   reliable=${reliable}
    ${response} =      Do API call    POST    ${RAW_MESSAGE_URL}/${collar_id}/getTrackingConfig    params=${params}    expected_status=${expected_status}    is_SECRET_PROJECT_user=${True}
    RETURN    ${response}
