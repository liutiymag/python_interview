*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${HERD_URL} =    ${BASE_URL_API}/herd

*** Keywords ***
Get Herd History
    [Arguments]     ${expected_status}=200   &{request_params}
    ${response} =   Do API call      GET     ${HERD_URL}/history     params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Herd Schedule History
    [Arguments]     ${expected_status}=200   &{request_params}
    ${response} =   Do API call      GET     ${HERD_URL}/schedule_history     params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Herd Collar History By Id
    [Arguments]     ${collar_history_id}     ${expected_status}=200
    ${response} =   Do API call      GET     ${HERD_URL}/collar_history/${collar_history_id}     expected_status=${expected_status}
    RETURN    ${response}

Get Collar History By Id In CSV
    [Arguments]     ${collar_history_id}     ${expected_status}=200
    ${response} =   Do API call      GET     ${HERD_URL}/collar_history/${collar_history_id}/collar/csv     expected_status=${expected_status}
    RETURN    ${response}

Get Collar History In CSV
    [Arguments]     ${expected_status}=200   &{request_params}
    ${response} =   Do API call      GET     ${HERD_URL}/collar_history/csv     params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Collar History From DB By Herd Id
    [Arguments]          ${herd_id}
    ${sql} =             Catenate       select id
    ...                                 from public.herd_collar_history
    ...                                 where herd_id='${herd_id}'
    ${query_result} =    Query To DB    ${sql}
    RETURN    ${query_result}
