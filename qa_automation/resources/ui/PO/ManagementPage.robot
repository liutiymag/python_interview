*** Settings ***
Library    SeleniumLibrary

Resource   ../PO/MapBasicPage.robot
Resource   ../PO/ManagementHerds.robot
Resource   ../PO/ManagementLandmarks.robot
Resource   ../PO/ManagementSECRET_PROJECTs.robot
Resource   ../../ui/Variables/landmark_types.robot

*** Variables ***
${CREATE_LANDMARK_BTN} =                     sh-id=create-landmark-main-panel-button
${VIEW_LANDMARKS_BTN} =                      sh-id=view-landmarks-main-panel-button
${CREATE_SECRET_PROJECT_BTN} =                        sh-id=create-SECRET_PROJECT-main-panel-button
${VIEW_HERDS_BTN} =                          sh-id=view-herds-main-panel-button
${VIEW_SECRET_PROJECTS_BTN} =                         sh-id=view-SECRET_PROJECTs-main-panel-button
${DELETE_LANDMARK_CNTX_MENU} =               sh-id=delete-landmark-context-menu-command
${DELETE_MSG_DLG_CONFIRM_BUTTON} =           sh-id=Delete-message-dialog-button
${DELETE_SECRET_PROJECT_CNTX_MENU} =                  sh-id=delete-SECRET_PROJECT-context-menu-command

*** Keywords ***
Verify Page Loaded
    Wait Until Page Contains Element     ${MAIN_MENU_MANAGEMENT_BTN}
    Element Attribute Value Should Be    ${MAIN_MENU_MANAGEMENT_BTN}    class    menu-item selected
    Verify Map Is Loaded

Click "Create Landmark"
    Click Button    ${CREATE_LANDMARK_BTN}
    Verify Create Landmark Menu Opened

Click "Create SECRET_PROJECT"
    Click Button    ${CREATE_SECRET_PROJECT_BTN}
    Verify Create SECRET_PROJECT Menu Opened

Create Landmark in UI
    [Documentation]    Create random landmark of specified type in UI way
    [Arguments]        ${name}  ${type}    
    IF  '${type}' == 'AREA_LANDMARKS'
        ${landmark_type} =      Evaluate        random.choice(${AREA_LANDMARKS_UI})
        ${points_number} =      Evaluate        random.randint(3, 9)
    ELSE IF    '${type}' == 'LINE_LANDMARKS'
        ${landmark_type} =      Evaluate        random.choice(${LINE_LANDMARKS_UI})
        ${points_number} =      Evaluate        random.randint(2, 7)
    ELSE IF    '${type}' == 'POINT_LANDMARKS'
        ${landmark_type} =      Evaluate        random.choice(${POINT_LANDMARKS_UI})
        ${points_number} =      Set Variable    1
    END
    
    Verify Page Loaded
    ${coords} =    Generate Landmark Coords     ${points_number}
    Click "Create Landmark"
    Choose Landmark Type        ${landmark_type}[button]
    Click UI Coords On Map      ${coords}    click_type=right_click
    Click "Save" Landmark
    Verify Landmark Info Form Is Opened
    Enter Landmark Name         ${name}
    Save Landmark Info
    Verify Landmark Info Form Is Closed

Delete Landmark From Context Menu
    [Documentation]  Delete landmark on coords related to the center of map
    [Arguments]    ${x_offset}=${null}    ${y_offset}=${null}    ${map_center}=${False}
    ${MAP} =  Verify Map Is Loaded
    IF  ${map_center}
         ${x_offset}    ${y_offset} =  Get Map Center Coords
    END
    # Moving a cursror from bottom of the icon up to 5 points    
    ${y_offset} =                      Evaluate    int(${y_offset}) - 5
    # Open context menu
    Move Cursor By Element Offset      ${MAP}    ${x_offset}    ${y_offset}
    Cursor Right Click
    # Choose Delete option
    Wait Until Element Is Visible      ${DELETE_LANDMARK_CNTX_MENU}    timeout=15
    Click Button                       ${DELETE_LANDMARK_CNTX_MENU}
    # Confirm deletion
    Wait Until Element Is Visible      ${DELETE_MSG_DLG_CONFIRM_BUTTON}    timeout=15
    Click Element                      ${DELETE_MSG_DLG_CONFIRM_BUTTON}
    Wait Until Page Does Not Contain   ${DELETE_MSG_DLG_CONFIRM_BUTTON}
    # Check landmark is not visible (context menu doesn't open)
    Move Cursor By Element Offset      ${MAP}    ${x_offset}    ${y_offset}
    Cursor Right Click
    Page Should Not Contain            ${DELETE_LANDMARK_CNTX_MENU}

Delete SECRET_PROJECT From View SECRET_PROJECTs
    [Documentation]  Delete SECRET_PROJECT on coords related to the center of map
    [Arguments]      ${name}
    Click "View SECRET_PROJECTs"
    Filter SECRET_PROJECT By Name    ${name}
    Select All SECRET_PROJECTs In View
    Click "Delete SECRET_PROJECT" In SECRET_PROJECTs View

    # Confirm deletion
    Wait Until Element Is Visible      ${DELETE_MSG_DLG_CONFIRM_BUTTON}    timeout=15
    Click Element                      ${DELETE_MSG_DLG_CONFIRM_BUTTON}
    Wait Until Page Does Not Contain   ${DELETE_MSG_DLG_CONFIRM_BUTTON}
    Sleep    1
    Clear Element Text                 ${SECRET_PROJECT_FILTER_VIEW_INPUT}

Generate Landmark Coords
    [Arguments]      ${points_number}    ${is_polygon}=${False}
    ${map_width}     ${map_height} =     Get Element Size    ${MAP_WINDOW}
    ${center_x}      ${center_y} =       Get Map Center Coords
    ${avg_radius} =  Evaluate            int(((${map_height}/2) - 10)/2)
    
    ${coords} =      Generate Ui Coordinates   points_number=${points_number}
    ...                                        center_x=${center_x}
    ...                                        center_y=${center_y}
    ...                                        avg_radius=${avg_radius}
    IF  ${is_polygon}
        Append To List    ${coords}    ${coords}[0]
    END    
    RETURN    ${coords}

Click "View Herds"
    Click Button    ${VIEW_HERDS_BTN}
    Verify View Herds Menu Opened

Click "View SECRET_PROJECTs"
    ${count} =    Get Element Count  ${VIEW_SECRET_PROJECTS_MENU_TITLE}
    IF    ${count}==${0}
        Click Button    ${VIEW_SECRET_PROJECTS_BTN}
        Verify View SECRET_PROJECTs Menu Opened
    END    
