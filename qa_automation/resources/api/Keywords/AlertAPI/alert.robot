*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${ALERT_URL} =  ${ALERT_URL_API}/alert-ms/v1/alert

*** Keywords ***
Create Alert
    [Arguments]    ${transportId}    ${APIalertsList}=${None}
    Create Collar Alert In Simulator    ${transportId}    ${APIalertsList}

Get Alerts
    [Arguments]    ${expected_status}=200    &{request_params}
    ${response} =  Do API call     GET       ${ALERT_URL}    params=${request_params}    expected_status=${expected_status}
    RETURN         ${response}

Get Alerts By Collar Id
    [Documentation]    Get alerts and filter them by collarId (deviceId). Return type: list(dict)
    [Arguments]    ${collar_id}    ${farm_id}=${None}
    ${response} =     Get Alerts    farmId=${farm_id}
    ${alerts_list} =  Create List
    FOR  ${alert}  IN  @{response.json()}
        IF  '${alert}[deviceId]'=='${collar_id}'
            Append To List    ${alerts_list}    ${alert}
        END
    END
    RETURN    ${alerts_list}

Get Alert By Id
    [Arguments]    ${alertId}    ${expected_status}=200
    ${response} =  Do API call     GET      ${ALERT_URL}/${alertId}    expected_status=${expected_status}
    RETURN         ${response}

Alerts Acknowledge
    [Arguments]    ${farmId}    ${alertIds}    ${expected_status}=204
    ${params} =    Create Dictionary           farmId=${farm_id}
    ${body} =      Create Dictionary           alertIds=${alertIds}
    ${response} =  Do API call     POST        ${ALERT_URL}/acknowledge    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Alert Acknowledge By Id
    [Arguments]    ${alertId}                  ${expected_status}=200
    ${response} =  Do API call     PUT         ${ALERT_URL}/${alertId}/acknowledge    json=${EMPTY}    expected_status=${expected_status}
    RETURN         ${response}

Alert Deactivate
    [Arguments]    ${farmId}    ${alertIds}    ${expected_status}=204
    ${params} =    Create Dictionary           farmId=${farm_id}
    ${body} =      Create Dictionary           alertIds=${alertIds}
    ${response} =  Do API call     POST        ${ALERT_URL}/deactivate    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}
