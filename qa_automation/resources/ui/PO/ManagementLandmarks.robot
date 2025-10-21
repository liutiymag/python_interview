*** Settings ***
Library    SeleniumLibrary

Resource   ../Variables/common_locators.robot

*** Variables ***
${CREATION_TOOLTIP_CLOSE_BTN} =    sh-id=snack-bar-action-button-Close
${CREATE_LANDMARK_PANEL} =         xpath=//landmark-create-panel
${LANDMARK_INFO_FORM} =            id=landmarkInfoForm
${SAVE_LANDMARK_PANEL} =           xpath=//landmark-edit-panel[//panel-header[@title="Save Landmark"]]
${SAVE_LANDMARK_BTN} =             sh-id=landmark-edit-panel-save-button
${CANCEL_LANDMARK_BTN} =           sh-id=landmark-edit-panel-cansel-button
${INPUT_NAME_FIELD} =              xpath=//input[@formcontrolname="name"]
${SELECT_TYPE_FIELD} =             xpath=//mat-select[@role="combobox" and @formcontrolname="type"]
${SAVE_LANDMARK_INFO_BTN} =        sh-id=landmark-info-ok

*** Keywords ***
Verify Create Landmark Menu Opened
    Wait Until Element Is Visible    ${CREATE_LANDMARK_PANEL}

Verify Save Landmark Menu Opened
    Wait Until Element Is Visible    ${SAVE_LANDMARK_PANEL}

Verify Landmark Info Form Is Opened
    Wait Until Element Is Visible    ${LANDMARK_INFO_FORM}

Verify Landmark Info Form Is Closed
    Wait Until Element Is Not Visible    ${LANDMARK_INFO_FORM}

Verify Landmark Type Name
    [Arguments]    ${type_name}
    Element Text Should Be    ${SELECT_TYPE_FIELD}    ${type_name}

Close Creation Tooltip
    Wait Until Element Is Visible    ${CREATION_TOOLTIP_CLOSE_BTN}    timeout=3
    Click Element                    ${CREATION_TOOLTIP_CLOSE_BTN}

Choose Landmark Type
    [Arguments]     ${type_btn}
    Click Button    ${type_btn}
    Verify Save Landmark Menu Opened
    Element Should Be Disabled    ${SAVE_LANDMARK_BTN}
    Element Should Be Enabled     ${CANCEL_LANDMARK_BTN}
    Close Creation Tooltip

Click "Save" Landmark
    Wait Until Element Is Enabled  ${SAVE_LANDMARK_BTN}
    Click Button                   ${SAVE_LANDMARK_BTN}

Clear Landmark Name
    Clear Element Text    ${INPUT_NAME_FIELD}

Enter Landmark Name
    [Arguments]   ${name}
    Element Text Should Be    ${INPUT_NAME_FIELD}    ${EMPTY}
    Input Text                ${INPUT_NAME_FIELD}    ${name}

Save Landmark Info
    Element Should Be Enabled    ${SAVE_LANDMARK_INFO_BTN}
    Click Button                 ${SAVE_LANDMARK_INFO_BTN}
