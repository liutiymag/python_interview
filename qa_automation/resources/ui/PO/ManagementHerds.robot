*** Settings ***
Library    SeleniumLibrary

Resource   ../Variables/common_locators.robot

*** Variables ***
${VIEW_HERDS_MENU_TITLE} =    xpath=//herd-panel//panel-header[@title="View Herds"]

*** Keywords ***
Verify View Herds Menu Opened
    Wait Until Page Contains Element    ${VIEW_HERDS_MENU_TITLE}
    