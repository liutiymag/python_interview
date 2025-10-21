*** Settings ***
Library    SeleniumLibrary
Library    ../../../libs/utils.py
Library    ../../../libs/SeleniumUtils.py

Resource   ../../ui/Variables/common_locators.robot

*** Variables ***
${MAP_WINDOW} =        id=map
${MAP_CONTROLS} =      css=button.map-control
${TOOLS_BAR} =         sh-id=toolbox
${PROGRESS_SPINNER} =  css=mat-spinner


*** Keywords ***
Verify Tools Panel Is Present
    Wait Until Element Is Visible        ${TOOLS_BAR}

Verify Map Is Loaded
    Wait Until Element Is Visible        ${MAP_CONTROLS}
    ${map_element} =  Get WebElement     ${MAP_WINDOW}
    Sleep     1
    RETURN    ${map_element}

Move Cursor To UI Coords On Map
    [Documentation]    Move cursor to coords related to the center of map
    [Arguments]        ${x_offset}   ${y_offset}       ${map_element}=${None}
    IF  $map_element==$None
        ${map_element} =  Verify Map Is Loaded
    END    
    Move Cursor By Element Offset    ${map_element}    ${x_offset}    ${y_offset}

Click On Map By Offset
    [Documentation]  Click cursor to coords related to the center of map
    [Arguments]      ${map_element}    ${x_offset}    ${y_offset}    
    Move Cursor To UI Coords On Map    ${x_offset}    ${y_offset}    ${map_element}
    Cursor Click

Click UI Coords On Map
    [Documentation]   Set points on map from list of UI coorinates
    [Arguments]       ${coords}        ${click_type}=double_click
    ${map_element} =  Verify Map Is Loaded
    IF  ${{len(${coords}) == 1}}
        Click On Map By Offset    ${map_element}    ${coords}[0][0]    ${coords}[0][1]
    ELSE
        FOR  ${point}  IN  @{coords}[:-1]
            Click On Map By Offset     ${map_element}    ${point}[0]    ${point}[1]
            Sleep  1
        END
        Move Cursor To UI Coords On Map  ${coords}[-1][0]    ${coords}[-1][1]    ${map_element}
        IF    "${click_type}" == 'double_click'
            Cursor Double Click
        ELSE IF    "${click_type}" == 'right_click'
            Cursor Right Click
        END
    END

Get Map Center Coords
    ${main_nav_width}  ${main_nav_height} =        Get Element Size    ${MAIN_MENU_NAVIGATION}
    ${tools_panel_width}  ${tools_panel_height} =  Get Element Size    ${TOOLS_BAR}
    ${map_width}  ${map_height} =                  Get Element Size    ${MAP_WINDOW}

    ${center_x} =        Evaluate                  int(-1 * (${tools_panel_width}-${main_nav_width}) / 2)
    RETURN    ${center_x}    0

Make Map Screenshot
    [Arguments]    ${file_path}
    Capture Element Screenshot    ${MAP_WINDOW}    ${file_path}

    ${main_nav_width}  ${main_nav_height} =        Get Element Size    ${MAIN_MENU_NAVIGATION}
    ${tools_panel_width}  ${tools_panel_height} =  Get Element Size    ${TOOLS_BAR}
    ${map_width}  ${map_height} =                  Get Element Size    ${MAP_WINDOW}
    
    ${x1} =  Evaluate        ${main_nav_width}+10
    ${y1} =  Set Variable    ${0}
    ${x2} =  Evaluate        ${map_width}-${tools_panel_width}-80
    ${y2} =  Evaluate        ${map_height}-40

    Crop Image    ${x1}    ${y1}    ${x2}    ${y2}    ${file_path}
