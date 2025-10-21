*** Settings ***
Library       String
Library       JSONLibrary

Resource      ../CommonAPI.robot

*** Variables ***
${USER_URL} =       ${BASE_URL_API}/user

*** Keywords ***
Create User
    [Documentation]     Creates user
    [Arguments]         ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${response} =       Create User Common    ${farm_id}    ${expected_status}    &{kwargs}
    RETURN  ${response}    

Create User With Password
    [Documentation]    Create user and return it's password
    [Arguments]        ${farm_id}=${None}    &{kwargs}
    ${password}        ${create_response} =  Create User With Password Common    ${farm_id}    &{kwargs}
    RETURN  ${password}    ${create_response}

Update User By ID
    [Documentation]     Update user's data
    [Arguments]         ${user_id}    ${expected_status}=200    &{kwargs}
    ${user_info_resp} =      Get User By ID         ${user_id}    
    ${user_info} =           Set Variable           ${user_info_resp.json()}
    FOR    ${key}    IN    @{kwargs}
        ${user_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${update_response} =    Do API call    PUT    ${USER_URL}/${user_id}      json=${user_info}    expected_status=${expected_status}
    RETURN    ${update_response}

Set User Status INACTIVE
    [Documentation]    Set user status INACTIVE
    [Arguments]        ${user_id}
    ${user_info_resp} =      Get User By ID          ${user_id}
    ${user_info} =           Set Variable            ${user_info_resp.json()}
    ${data} =                Update Value To Json    ${user_info}     status      INACTIVE
    Do API call       PUT    ${USER_URL}/${user_id}  json=${data}     expected_status=200

Get Users
    [Documentation]     Get users list
    [Arguments]         ${expected_status}=200  ${request_params}=${None}
    ${response} =       Do API call    GET      ${USER_URL}    params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get User By ID
    [Documentation]     Get user data by ID
    [Arguments]         ${user_id}     ${expected_status}=200
    ${response} =       Do API call    GET      ${USER_URL}/${user_id}    expected_status=${expected_status}
    RETURN              ${response}

Get User By Name
    [Documentation]     Get user data by username
    [Arguments]         ${username}    ${users_list}=${None}
    IF  ${{$users_list is None}}
        ${response} =   Get Users
    ELSE
        ${response} =   Set Variable    ${users_list}
    END
    ${users_info} =     Set Variable    ${response.json()}
    FOR  ${user}  IN  @{users_info}
        IF    "${user}[username]" == "${username}"
            RETURN    ${user}
        END
    END
    Fail    User with name "${username}" not found

Generate Username
    [Documentation]     Generates random username
    ${username} =       Generate Username Common
    RETURN  ${username}

Unlock User By ID
    [Documentation]     Unlock user
    [Arguments]         ${user_id}    ${expected_status}=204
    ${response} =       Do API call    PUT    ${USER_URL}/${user_id}/unlock  json=${EMPTY}    expected_status=${expected_status}
    RETURN    ${response}

Get User Self Info
    [Documentation]     Get user self info
    [Arguments]         ${expected_status}=200
    ${response} =       Do API call    GET      ${USER_URL}/self    expected_status=${expected_status}
    RETURN    ${response}

Get User Help
    [Documentation]     Get user help
    [Arguments]         ${expected_status}=200
    ${response} =       Do API call    GET      ${USER_URL}/help    expected_status=${expected_status}
    RETURN    ${response}

Get User Farm
    [Documentation]     Get user farm
    [Arguments]         ${expected_status}=200
    ${response} =       Do API call    GET      ${USER_URL}/farm    expected_status=${expected_status}
    RETURN    ${response}

Update User View Farm ID
    [Documentation]     Update user viewFarmId
    [Arguments]         ${farm_id}    ${expected_status}=200    
    ${response} =       Do API call    PUT    ${USER_URL}/farm/${farm_id}    json=${EMPTY}    expected_status=${expected_status}
    RETURN    ${response}

Update User Password
    [Documentation]     Update user password
    [Arguments]         ${password}           ${expected_status}=204
    ${body} =           Create Dictionary     password=${password}
    ${response} =       Do API call    PUT    ${USER_URL}/password    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Set Subscribed User Alerts
    [Documentation]    Set subscribed user alerts for a farm
    [Arguments]        ${alertsList}=${None}    ${expected_status}=200    &{request_params}
    ${body} =          Create Dictionary

    IF  '${alertsList}'!='${None}'
        ${body}[types] =    Set Variable    ${alertsList}
    ELSE
        ${body}[types] =    Get Dictionary Values    ${ALERT_TYPES}
    END

    ${response} =      Do API call    PUT    ${USER_URL}/ui/alert    params=${request_params}    json=${body}    expected_status=${expected_status}
    RETURN    ${response}
