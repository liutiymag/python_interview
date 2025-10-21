*** Settings ***
Library      SeleniumLibrary

Resource     ../PO/MapBasicPage.robot

*** Variables ***
${SELECT_GRAZING_BTN} =            sh-id=select-grazing-data-main-panel-button
${GRAZING_DATA_DIALOG} =           xpath=//dialog-header-deprecated[@headertitle="Grazing Data"]
${GRAZING_DATA_DIALOG_NEXT_BTN} =  sh-id=grazing-data-select-next-header-button
${USE_ALL_COLLARS_BTN} =           sh-id=grazing-data-select-use-all-collars-radio-button
${USE_SPECIFIC_COLLARS_BTN} =      sh-id=grazing-data-select-specific-collars-radio-button
${DATE_INPUT_FROM} =               sh-id=date-input-date-range-from
${DATE_INPUT_TO} =                 sh-id=date-input-date-range-to
${GRAZING_DIALOG_OK_BTN} =         sh-id=grazing-data-ok
${GRAZING_PLAYER_BTN} =            xpath=//video-player//button


*** Keywords ***
Verify Grazing Page Is Loaded
    Wait Until Page Contains Element     ${MAIN_MENU_GRAZING_BTN}
    Element Attribute Value Should Be    ${MAIN_MENU_GRAZING_BTN}    class    menu-item selected
    Verify Map Is Loaded

Click Select Grazing Data Button
    Click Button    ${SELECT_GRAZING_BTN}
    Sleep           500ms
    Verify Grazing Data Dialog Is Opened

Verify Grazing Data Dialog Is Opened
    Wait Until Page Contains Element    ${GRAZING_DATA_DIALOG}    timeout=10

Select Herd In Grazing List
    [Arguments]    ${herd_id}
    ${herd_checkbox} =             Set Variable    xpath=//div[@sh-id="herd-tree-list-item-${herd_id}"]//input[@type="checkbox"]
    Select Checkbox                ${herd_checkbox}
    Checkbox Should Be Selected    ${herd_checkbox}

Click Next In Grazing Dialog
    Element Should Be Enabled        ${GRAZING_DATA_DIALOG_NEXT_BTN}
    Click Button                     ${GRAZING_DATA_DIALOG_NEXT_BTN}

Check Collars Selection Is Available
    Wait Until Page Contains Element  ${USE_ALL_COLLARS_BTN}
    Wait Until Page Contains Element  ${USE_SPECIFIC_COLLARS_BTN}

Set "Use all collars"
    Click Element       ${USE_ALL_COLLARS_BTN}
    ${class_value} =    Get Element Attribute    ${USE_ALL_COLLARS_BTN}    class
    Should Contain      ${class_value}           mat-mdc-radio-checked     "Use all collars" radio button is not checked

Select Grazing From Date
    [Arguments]    ${from_date}
    Input Text     ${DATE_INPUT_FROM}    ${from_date}

Select Grazing To Date
    [Arguments]    ${to_date}
    Input Text     ${DATE_INPUT_TO}      ${to_date}

Click Ok Button On Grazing Select
    Click Button                       ${GRAZING_DIALOG_OK_BTN}
    Sleep                              500ms
    Page Should Not Contain Element    ${GRAZING_DATA_DIALOG}

Wait For Grazing Is Displayed
    Wait Until Element Is Not Visible  ${PROGRESS_SPINNER}
    Wait Until Element Is Visible      ${GRAZING_PLAYER_BTN}

Check If Grazing Is Displayed
    [Arguments]    ${map_without_grazing_path}    ${map_with_grazing_path}
    ${comparison_value} =       Compare Images Histograms    ${map_without_grazing_path}    ${map_with_grazing_path}
    IF  ${comparison_value}>=${0.08}
        RETURN    ${True}
    ELSE
        RETURN    ${False}
    END

Check Date Error Message
    [Arguments]    ${field}    ${msg}
    # Acceptable field values: From, To
    Element Should Be Visible    //mat-label/span[.="${field}"]/following-sibling::span[.=" ${msg}"]
    
