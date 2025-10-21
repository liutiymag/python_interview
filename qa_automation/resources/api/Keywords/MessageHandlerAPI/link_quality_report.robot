*** Settings ***
Resource      ../CommonAPI.robot
Resource      ../HerdManagerAPI/collar.robot

*** Variables ***
${LINK_QUALITY_REPORT_URL} =    ${MESSAGE_HANDLER_URL_API}/message-handler/v1/link

*** Keywords ***
Create New LinkQualityReport
    [Documentation]  Create LinkQualityReport. Return type: response
    [Arguments]      ${farm_id}   ${expected_status}=200    &{kwargs}
    ${params} =      Create Dictionary         farmId=${farm_id}
    ${name} =        Generate Random String    ${128}
    ${body} =        Create Dictionary         name=${name}
    ...                                        time=${0}
    IF  ${{'collarIds' not in $kwargs}}
        ${create_collar} =  Create New Collar  ${farm_id}
        ${collar_ids} =     Create List        ${create_collar}[id]
        ${body}[collarIds] =  Set Variable     ${collar_ids}
    END
    FOR  ${field}  IN  @{kwargs}
        ${body}[${field}] =  Set Variable    ${kwargs}[${field}]
    END
    
    ${response} =    Do API call    POST       ${LINK_QUALITY_REPORT_URL}    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Get LinkQualityReports
    [Documentation]  Get LinkQualityReports. Return type: response
    [Arguments]      ${expected_status}=200    &{params}
    ${response} =    Do API call    GET    ${LINK_QUALITY_REPORT_URL}    params=${params}    expected_status=${expected_status}
    RETURN    ${response}

Get LinkQualityReport By ID
    [Documentation]  Get LinkQualityReport by id. Return type: response
    [Arguments]      ${link_id}   ${expected_status}=200
    ${response} =    Do API call    GET    ${LINK_QUALITY_REPORT_URL}/${link_id}    expected_status=${expected_status}
    RETURN    ${response}

Update LinkQualityReport By ID
    [Documentation]  Update LinkQualityReport. Return type: response
    [Arguments]      ${link_id}   ${expected_status}=200    &{kwargs}
    ${info_resp} =   Get LinkQualityReport By ID    ${link_id}
    ${body} =        Create Dictionary              id=${info_resp.json()}[id]
    ...                                             name=${info_resp.json()}[name]
    ...                                             date=${info_resp.json()}[date]
    ...                                             time=${info_resp.json()}[time]
    ...                                             version=${info_resp.json()}[version]
    ...                                             modifyDate=${info_resp.json()}[modifyDate]
    FOR  ${field}  IN  @{kwargs}
        ${body}[${field}] =  Set Variable    ${kwargs}[${field}]
    END

    ${response} =    Do API call    PUT    ${LINK_QUALITY_REPORT_URL}/${link_id}    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Cancel LinkQualityReport
    [Documentation]  Cancel LinkQualityReport. Return type: response
    [Arguments]      ${link_id}   ${expected_status}=204
    ${response} =    Do API call    POST    ${LINK_QUALITY_REPORT_URL}/${link_id}/cancel    expected_status=${expected_status}
    RETURN    ${response}

Get LinkQualityReport Statistics
    [Documentation]  Get LinkQualityReport statistics by id. Return type: response
    [Arguments]      ${link_id}   ${expected_status}=200
    ${response} =    Do API call    GET    ${LINK_QUALITY_REPORT_URL}/${link_id}/statistics    expected_status=${expected_status}
    RETURN    ${response}

Check If LinkQualityReport Is Completed
    [Documentation]  Check if report is completed. Return type: void.
    [Arguments]    ${link_id}
    ${response} =  Get LinkQualityReport By ID    ${link_id}
    Should Be Equal As Strings    ${response.json()}[state]    COMPLETED

Create LinkQualityReport CSV Token
    [Documentation]  Build Logged in User token, that would be used to initialize file loading. Return type: response.
    [Arguments]      ${expected_status}=200
    ${response} =    Do API call    POST    ${LINK_QUALITY_REPORT_URL}/csv/token    expected_status=${expected_status}
    RETURN    ${response}

Get LinkQualityReport Statistics CSV
    [Documentation]  Get LinkQualityStatistics CSV. Return type: response
    [Arguments]      ${link_id}   ${expected_status}=200
    ${response} =    Do API call    GET    ${LINK_QUALITY_REPORT_URL}/${link_id}/statistics/csv    expected_status=${expected_status}
    RETURN    ${response}
