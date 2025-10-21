*** Settings ***
Resource    ../CommonAPI.robot
Resource    ./user.robot

*** Variables ***
${LOGIN_URL} =    ${BASE_URL_API}/login

*** Keywords ***
User Login
    [Arguments]    ${username}    ${password}    ${expected_status}=any
	${response} =  User Login Common    ${username}    ${password}    ${expected_status}
    RETURN         ${response}

Lock User by Wrong Login
    [Arguments]    ${user_id}    ${username}    ${password}
    ${requests_number_to_lock} =    Set Variable        3
    # Do unseccessfull login
    FOR  ${indx}  IN RANGE    ${requests_number_to_lock}
        ${data} =      Create dictionary    username=${username}    password=${password}_wrong
        Do API call    POST    ${LOGIN_URL}    json=${data}    expected_status=any        
    END
    # Check user is locked
    ${locked_user_info} =    Get User By ID    ${user_id}
    Should Be Equal As Strings    ${locked_user_info.json()}[locked]    True
    Log To Console                User id "${user_id}" is locked
    