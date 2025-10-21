*** Settings ***
Library  SeleniumLibrary

Resource    ../../EnvVariablesData.robot

*** Variables ***
${LOGIN_PAGE_URL} =          ${BASE_URL_UI}/#/login
${LOG_IN_EMAIL_LABEL} =      id=username-label
${LOG_IN_PASSWORD_LABEL} =   id=password-label
${LOG_IN_EMAIL_FIELD} =      id=username
${LOG_IN_PASSWORD_FIELD} =   id=password
${LOGIN_SUBMIT_BUTTON} =     id=login

*** Keywords ***
Verify Page Loaded
    Wait Until Page Contains Element    ${LOG_IN_EMAIL_LABEL}
    Wait Until Page Contains Element    ${LOG_IN_PASSWORD_LABEL}
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}
    Element Should Be Disabled          ${LOGIN_SUBMIT_BUTTON}

Login With User
    [Arguments]          ${email}    ${password}
    Enter Credentials    ${email}    ${password}    
    Click "Login" Button

Enter Credentials
    [Arguments]            ${email}    ${password}
    Fill "Email" Field     ${email}
    Fill "Password" Field  ${password}

Fill "Email" Field
    [Arguments]      ${username}
    Input Text       ${LOG_IN_EMAIL_FIELD}    ${username}

Fill "Password" Field
    [Arguments]  ${password}
    Input Text   ${LOG_IN_PASSWORD_FIELD}     ${password}

Check "Login" Button is Inactive And Click
    Element Should Be Disabled    ${LOGIN_SUBMIT_BUTTON}
    TRY
        Click "Login" Button
    EXCEPT    Element '${LOGIN_SUBMIT_BUTTON}' is disabled.
        Log To Console    Login button is not clickable
    END

Click "Login" Button
    Element Should Be Enabled    ${LOGIN_SUBMIT_BUTTON}
    Click Button                 ${LOGIN_SUBMIT_BUTTON}

Check "Email" Field is Empty
    Textfield Value Should Be    ${LOG_IN_EMAIL_FIELD}    ${EMPTY}

Check "Password" Field is Empty
    Textfield Value Should Be    ${LOG_IN_PASSWORD_FIELD}    ${EMPTY}
