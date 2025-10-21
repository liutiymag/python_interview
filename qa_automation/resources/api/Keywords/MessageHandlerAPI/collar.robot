*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${COLLAR_MESSAGE_URL} =    ${MESSAGE_HANDLER_URL_API}/message-handler/v1/collar

*** Keywords ***
Get Pending Messages Types
    [Documentation]    Get Map of pending messages linked to their Collar Transport IDs. Return type: response.
    [Arguments]        ${farm_id}             ${expected_status}=200
    ${params} =        Create Dictionary      farmId=${farm_id}
    ${response} =      Do API call    GET     ${COLLAR_MESSAGE_URL}/pendingMessageTypes    params=${params}    expected_status=${expected_status}    is_SECRET_PROJECT_user=${True}
    RETURN    ${response}
