*** Settings ***
Library       String

Resource      ../CommonAPI.robot
Resource      ../../Variables/messageGroup.robot

*** Variables ***
${MESSAGE_GROUP_URL} =              ${BASE_URL_API}/messageGroup

*** Keywords ***
Create New MessageGroup
    [Arguments]    ${expected_status}=200    &{kwargs}

    ${messageGroup_info} =                Create Dictionary
    ${messageGroup_info}[name] =          Generate Random String    128
    ${messageGroup_info}[messages] =      Evaluate                  random.sample(${MESSAGE_GROUP_TYPES}, 2)

    FOR    ${key}    IN    @{kwargs}
        ${messageGroup_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    # Create messageGroup
    ${response} =   Do API call      POST     ${MESSAGE_GROUP_URL}     json=${messageGroup_info}    expected_status=${expected_status}
    IF  ${{${response.status_code} == 200}}
        Log To Console  Created messageGroup with id "${response.json()}[id]"
    END
    RETURN  ${response}

Get Message Groups
    [Arguments]    ${expected_status}=200    &{request_params}
    ${response} =  Do API call    GET    ${MESSAGE_GROUP_URL}    params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get MessageGroup By Id
    [Arguments]    ${group_id}    ${expected_status}=200
    ${response} =  Do API call     GET      ${MESSAGE_GROUP_URL}/${group_id}    expected_status=${expected_status}
    RETURN         ${response}

Update MessageGroup By Id
    [Arguments]    ${group_id}    ${expected_status}=200    &{kwargs}
    ${info_response} =    Get MessageGroup By Id    group_id=${group_id}
    # Update messageGroup
    ${group_info} =       Set Variable              ${info_response.json()}
    FOR    ${key}    IN    @{kwargs}
        ${group_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =    Do API call    PUT    ${MESSAGE_GROUP_URL}/${group_id}    json=${group_info}    expected_status=${expected_status}
    RETURN    ${response}
