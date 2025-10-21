*** Settings ***
Library    SeleniumLibrary

Resource   ../Variables/common_locators.robot

*** Variables ***
${USERS_LIST_GRID} =      id=user-list-footer
${ADD_USER_BTN} =         sh-id=page-header-button-user-list-new
${USER_INFO_FORM} =       id=userInfoForm
${EMAIL_FIELD} =          sh-id=user-info-username-input
${FIRST_NAME_FIELD} =     sh-id=user-info-first-name-input
${LAST_NAME_FIELD} =      sh-id=user-info-last-name-input
${USER_ROLE_FIELD} =      sh-id=user-info-role-select
${ROLES_SELECT_LIST} =    id=role-panel
${PHONE_FIELD} =          sh-id=user-info-cell-phone-input
${ADD_USER_SAVE_BTN} =    sh-id=user-info-ok

*** Keywords ***
Users Page Is Opened
    Wait Until Element Is Visible    ${USERS_LIST_GRID}

Click "Add New User" Button
    Click Button                     ${ADD_USER_BTN}
    Wait Until Element Is Visible    ${USER_INFO_FORM}

Fill Email Address
    [Arguments]    ${email}
    Input Text     ${EMAIL_FIELD}    ${email}

Fill First Name
    [Arguments]    ${first_name}
    Input Text     ${FIRST_NAME_FIELD}    ${first_name}

Fill Last Name
    [Arguments]    ${last_name}
    Input Text     ${LAST_NAME_FIELD}    ${last_name}

Choose User Role
    [Arguments]    ${role}
    Click Element  ${USER_ROLE_FIELD}
    Wait Until Element Is Visible    ${ROLES_SELECT_LIST}
    Click Element  sh-id=user-info-role-select-item-${role}

Fill Phone Number
    [Arguments]    ${phone}
    Input Text     ${PHONE_FIELD}    ${phone}

Click "Save" Button
    Element Should Be Enabled            ${ADD_USER_SAVE_BTN}
    Click Button                         ${ADD_USER_SAVE_BTN}

Save User Info
    Click "Save" Button
    Wait Until Element Is Not Visible    ${USER_INFO_FORM}

Check User Email Is Present In List
    [Arguments]    ${email}
    Page Should Contain Element    //div[@col-id="username" and .="${email}"]

Check Email Label Text
    [Arguments]    ${text}
    Element Should Be Visible    //mat-label[@id="username-label"]//span[.="${text}"]

Check First Name Label Text
    [Arguments]    ${text}
    Element Should Be Visible    //mat-label[@id="first-name-label"]//span[.="${text}"]

Check Last Name Label Text
    [Arguments]    ${text}
    Element Should Be Visible    //mat-label[@id="last-name-label"]//span[.="${text}"]

Check Role Label Text
    [Arguments]    ${text}
    Element Should Be Visible    //mat-label[@id="role-label"]//span[.="${text}"]

Check Phone Label Text
    [Arguments]    ${text}
    Element Should Be Visible    //mat-label[@id="phone-label"]//span[.="${text}"]

Delete User
    [Arguments]    ${email}
    ${delete_btn} =  Set Variable    xpath=//div[@col-id="username" and .="${email}"]/following-sibling::div[@col-id="userDelete"]//button
    Click Button    ${delete_btn}
    Wait Until Page Does Not Contain Element    //div[@col-id="username" and .="${email}"]
