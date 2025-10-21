*** Settings ***
Library  SeleniumLibrary

*** Variables ***
${PROFILE_DIALOG_LOGOUT_BTN} =      xpath=//dialog-profile//button[//span[.="Logout"]]
${MESSAGE_DIALOG_LOGOUT_BTN} =      sh-id=Logout-message-dialog-button

*** Keywords ***
Verify Dialog is Opened
    Wait Until Element Is Visible    ${PROFILE_DIALOG_LOGOUT_BTN}

Click "Logout" Profile Button
    Click Button                     ${PROFILE_DIALOG_LOGOUT_BTN}
    Wait Until Element Is Visible    ${MESSAGE_DIALOG_LOGOUT_BTN}

Click "Logout" Message Button
    Click Button    ${MESSAGE_DIALOG_LOGOUT_BTN}
