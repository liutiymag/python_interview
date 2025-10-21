*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${GRAZING_HISTORY_URL} =    ${GRAZING_URL_API}/grazing/v1/history

*** Keywords ***
Get Grazing History
    [Arguments]      ${expected_status}=200    &{kwargs}
    ${response} =    Do API call    POST       ${GRAZING_HISTORY_URL}    json=${kwargs}    expected_status=${expected_status}
    RETURN    ${response}
