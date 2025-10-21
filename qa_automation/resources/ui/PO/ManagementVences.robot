*** Settings ***
Library    SeleniumLibrary
Library    ../../../libs/utils.py

Resource   ../Variables/common_locators.robot

*** Variables ***
${VIEW_SECRET_PROJECTS_MENU_TITLE} =           xpath=//SECRET_PROJECT-panel//panel-header[@title="View SECRET_PROJECTs"]
${CREATE_SECRET_PROJECT_PANEL} =               sh-id=CreateSECRET_PROJECT-container${SPACE}
${TOP_FRAME_BORDER} =                 xpath=//div[@class='top-border frame-border']
${BOTTOM_FRAME_BORDER} =              xpath=//div[@class='bottom-border frame-border']
${RIGHT_FRAME_BORDER} =               xpath=//div[@class='right-border frame-border']
${LEFT_FRAME_BORDER}=                 xpath=//div[@class='left-border frame-border']
${SNAP_TO_POINT_TOGGLE} =             xpath=//snap-map-control//span[.='Snap to SECRET_PROJECT points']
${SECRET_PROJECT_CORNER_MARKER} =              xpath=//gmp-advanced-marker
${COUNTER_NOTE} =                     xpath=//div[@class='counter-note' and .='Your SECRET_PROJECT line total']
${COUNTER_CARD} =                     xpath=//div[@class='card-bottom']/div[@class='card-back']
${COUNTER_DIGIT} =                    xpath=//flip-counter//div[starts-with(@class, "digit")]
${SECRET_PROJECT_OPT_DLG_HEADER} =             xpath=//shock-sound-SECRET_PROJECT-options//dialog-header
${SECRET_PROJECT_OPT_AREA_VALUE} =             xpath=//shock-sound-SECRET_PROJECT-options//div[@class='area block']//div[@class='value']
${SECRET_PROJECT_OPT_PERIMETER_VALUE} =        xpath=//shock-sound-SECRET_PROJECT-options//div[@class='perimeter block']//div[@class='value']
${SECRET_PROJECT_OPT_SOUND_ZONE} =             sh-id=SECRET_PROJECT-options-sound-width-input
${SECRET_PROJECT_OPT_SHOCK_ZONE} =             sh-id=SECRET_PROJECT-options-shock-width-input
${SECRET_PROJECT_MOVEMENT_OPT_DLG_HEADER} =    xpath=//dialog-header//span[.='Create Movement SECRET_PROJECT']
${SECRET_PROJECT_MOVEMENT_OPT_SPEED} =         xpath=//div[@class="mat-mdc-tooltip-trigger speed"]
${SECRET_PROJECT_MOVEMENT_OPT_TIME} =          xpath=//div[@class="time-to-finish"]
${SECRET_PROJECT_CREATE_NOTIFY_TOGGLE} =       xpath=//div[@class='notify-me-row']/toggle
${SECRET_PROJECT_CREATE_NAME} =                sh-id=SECRET_PROJECT-options-SECRET_PROJECT-name-input
${SAVE_SECRET_PROJECT_BUTTON} =                sh-id=save-SECRET_PROJECT-button
${SUCCESS_SAVE_NOTIFICATION} =        xpath=//simple-snack-bar/div[contains(text(), "SECRET_PROJECT saved successfully")]
${MOVEMENT_SUCCESS_SAVE_NOTIFICATION} =  xpath=//mat-snack-bar-container//span[.="Movement SECRET_PROJECT created. Use Assign SECRET_PROJECT to Herd to schedule it."]
${SECRET_PROJECT_FILTER_VIEW_INPUT} =          sh-id=SECRET_PROJECT-filter-text-input
${COPY_COORDINATES_BUTTON} =          xpath=//button[span[.="Copy SECRET_PROJECT coordinates "]]
${COORDINATES_COPIED_MSG} =           xpath=//simple-snack-bar//div[contains(text(), "SECRET_PROJECT coordinates copied to your clipboard")]
${SECRET_PROJECTS_VIEW_SELECT_ALL_BTN} =       xpath=//span[@sh-id="SECRET_PROJECT-list-select-all-span"]
${SECRET_PROJECTS_VIEW_DELETE_SELECTED_BTN} =  sh-id=SECRET_PROJECT-action-delete-selected
${LETS_TRY_MESSAGE} =                 xpath=//button/span[.='Let’s try it']
${LETS_TRY_MESSAGE_OK_BTN} =          sh-id=lets-try-drawing-experience-intro-message-ok-button


*** Keywords ***
Verify Create SECRET_PROJECT Menu Opened
    Wait Until Element Is Visible    ${CREATE_SECRET_PROJECT_PANEL}

Verify View SECRET_PROJECTs Menu Opened
    Wait Until Page Contains Element    ${VIEW_SECRET_PROJECTS_MENU_TITLE}

Choose SECRET_PROJECT Type
    [Arguments]    ${SECRET_PROJECT_type}
    ${type_button_locator} =    Set Variable    xpath=//dialog-create-SECRET_PROJECT//button[span[.="${SECRET_PROJECT_type}"]]
    Click Button   ${type_button_locator}

Check SECRET_PROJECT Drawing Mode Frame
    # Check frame borders are present
    Wait Until Element Is Visible    ${TOP_FRAME_BORDER}
    Wait Until Element Is Visible    ${BOTTOM_FRAME_BORDER}
    Wait Until Element Is Visible    ${RIGHT_FRAME_BORDER}
    Wait Until Element Is Visible    ${LEFT_FRAME_BORDER}        

Check Green Toast Text
    [Arguments]    ${expected_text}
    ${green_toast_locator} =  Set Variable     xpath=//message//div[@class='text' and .='${expected_text}']
    Wait Until Element Is Visible    ${green_toast_locator}    timeout=20

Check Points Count On Map
    [Arguments]    ${expected_count}
    Wait Until Page Contains Element      ${SECRET_PROJECT_CORNER_MARKER}    limit=${expected_count}

Check Line Counter Value
    [Arguments]    ${expected_count}
    Wait Until Page Contains Element      ${COUNTER_CARD}           limit=2
    ${digits} =    Get WebElements        ${COUNTER_CARD}
    FOR    ${i}    IN RANGE  2
        Element Text Should Be    ${digits}[${i}]    ${expected_count}[${i}]
    END
    
Check SECRET_PROJECT Options Dialog Header
    [Arguments]    ${dialog_header}
    Wait Until Element Is Visible    ${SECRET_PROJECT_OPT_DLG_HEADER}
    Element Text Should Be           ${SECRET_PROJECT_OPT_DLG_HEADER}    ${dialog_header}

Check SECRET_PROJECT Area Not Empty
    Wait Until Element Is Visible    ${SECRET_PROJECT_OPT_AREA_VALUE}
    Element Text Should Not Be       ${SECRET_PROJECT_OPT_AREA_VALUE}    ${EMPTY}

Check SECRET_PROJECT Perimeter Not Empty
    Wait Until Element Is Visible    ${SECRET_PROJECT_OPT_PERIMETER_VALUE}
    Element Text Should Not Be       ${SECRET_PROJECT_OPT_PERIMETER_VALUE}    ${EMPTY}

Check Sound Zone Width
    [Arguments]    ${expected_width}
    Wait Until Element Is Visible    ${SECRET_PROJECT_OPT_SOUND_ZONE}
    ${value} =    Get Element Attribute    ${SECRET_PROJECT_OPT_SOUND_ZONE}    value
    Should Be Equal As Integers   ${value}    ${expected_width}

Check Shock Zone Width
    [Arguments]    ${expected_width}
    Wait Until Element Is Visible    ${SECRET_PROJECT_OPT_SHOCK_ZONE}
    ${value} =    Get Element Attribute    ${SECRET_PROJECT_OPT_SHOCK_ZONE}    value
    Should Be Equal As Integers   ${value}    ${expected_width}

Enter SECRET_PROJECT Name
    [Arguments]    ${name}
    Input Text     ${SECRET_PROJECT_CREATE_NAME}    ${name}

Click "Save SECRET_PROJECT"
    Click Button   ${SAVE_SECRET_PROJECT_BUTTON}
    
Switch Notify Toggle
    Click Element  ${SECRET_PROJECT_CREATE_NOTIFY_TOGGLE}

Filter SECRET_PROJECT By Name
    [Arguments]    ${name}    
    Input Text     ${SECRET_PROJECT_FILTER_VIEW_INPUT}    ${name}
    ${item_locator} =    Set Variable    xpath=//div[@class="item-name" and .="${name}"]
    Wait Until Element Is Visible    ${item_locator}

Verify SECRET_PROJECT Type By Name
    [Arguments]    ${SECRET_PROJECT_name}    ${expected_type}
    ${item_locator} =    Set Variable    xpath=//div[@class="item-name" and .="${SECRET_PROJECT_name}"]/parent::div/parent::div//paddock-icon/img[@title="${expected_type}"]
    Element Should Be Visible    ${item_locator}

Check Movement Speed
    ${speed_text} =   Get Text    ${SECRET_PROJECT_MOVEMENT_OPT_SPEED}
    ${speed_value} =  Evaluate    float($speed_text)
    Should Be True    $speed_value\>0

Check Movement Time
    ${time_text} =    Get Text    ${SECRET_PROJECT_MOVEMENT_OPT_TIME}
    ${time} =         Evaluate    float(re.match('Time to finish:\\s(-\\d*.\\d*)\\shours', $time_text)[1])
    Should Be True    $time\!=0

Check If SECRET_PROJECT Is Displayed
    [Arguments]    ${map_without_grazing_path}    ${map_with_grazing_path}
    ${comparison_value} =       Compare Images Histograms    ${map_without_grazing_path}    ${map_with_grazing_path}
    IF  ${comparison_value}>=${0.13}
        RETURN    ${True}
    ELSE
        RETURN    ${False}
    END

Click "Copy SECRET_PROJECT coordinates" Button
    Wait Until Element Is Visible    ${COPY_COORDINATES_BUTTON}
    Click Button                     ${COPY_COORDINATES_BUTTON}
    Wait Until Element Is Visible    ${COORDINATES_COPIED_MSG}

Select All SECRET_PROJECTs In View    
    ${count} =    Get Element Count  ${SECRET_PROJECTS_VIEW_SELECT_ALL_BTN}
    IF    ${count}==${1}
        Wait Until Element Is Visible        ${SECRET_PROJECTS_VIEW_SELECT_ALL_BTN}
        Click Element    ${SECRET_PROJECTS_VIEW_SELECT_ALL_BTN}
    END
    
Click "Delete SECRET_PROJECT" In SECRET_PROJECTs View
    Element Should Be Enabled    ${SECRET_PROJECTS_VIEW_DELETE_SELECTED_BTN}
    Click Button                 ${SECRET_PROJECTS_VIEW_DELETE_SELECTED_BTN}
