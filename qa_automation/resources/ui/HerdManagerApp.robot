*** Settings ***
Resource    ../api/Keywords/CommonAPI.robot
Resource    ../ui/Variables/common_locators.robot
Resource    ./PO/LoginPage.robot
Resource    ./PO/UsersPage.robot
Resource    ./PO/GrazingPage.robot
Resource    ./PO/ManagementPage.robot
Resource    ./PO/UserProfileDialog.robot

*** Variables ***
${BROWSER} =                chrome
${LOGGED_USER_EMAIL}
${LOGGED_USER_PASS}

*** Keywords ***
ShId Locator Strategy
    [Arguments]    ${browser}  ${locator}  ${tag}  ${constraints}
    ${element} =   Get WebElement  xpath=//*[@sh-id='${locator}']
    RETURN	${element}

Open Browser On Login Page
    Set Selenium Timeout     10
    ${bs_run} =              Get Variable Value   $IS_BROWSERSTACK
    IF  $bs_run==${None}
        # Run on agent and localy in headless mode
        Open Browser         ${LOGIN_PAGE_URL}    ${BROWSER}    options=add_argument("--window-size=1920,1080");add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--headless")
    ELSE
        # Run on BrowserStack with visible browser
        Open Browser         ${LOGIN_PAGE_URL}    ${BROWSER}
        Set Browserstack Session Name
    END
    Maximize Browser Window
    Add Location Strategy    sh-id    ShId Locator Strategy
    Login Page is Loaded

Open Browser And Login
    Open Browser On Login Page
    IF  'role:ROLE_ADMIN' in @{TEST_TAGS}
        ${email}  ${password} =  Get Predefined User Creds    ROLE_ADMIN
    ELSE IF  'role:ROLE_MANAGER' in @{TEST_TAGS}
        ${email}  ${password} =  Get Predefined User Creds    ROLE_MANAGER
    ELSE IF  'role:ROLE_USER' in @{TEST_TAGS}
        ${email}  ${password} =  Get Predefined User Creds    ROLE_USER
    ELSE IF  'role:ROLE_SECRET_PROJECT' in @{TEST_TAGS}
        ${email}  ${password} =  Get Predefined User Creds    ROLE_SECRET_PROJECT
    ELSE
        ${email}  ${password} =  Get Random Predefined User
    END
    UI User Login    ${email}    ${password}
    
    Set Test Variable    $LOGGED_USER_EMAIL    ${email}
    Set Test Variable    $LOGGED_USER_PASS     ${password}

End Web Test
    Close Browser
    Clean Up

UI User Login
    [Arguments]    ${email}    ${password}
    Login With User    ${email}    ${password}
    Management Page is Loaded

Get Predefined User Creds
    [Arguments]    ${role}
    IF  '${role}' == 'ROLE_ADMIN'
        RETURN    ${UI_ADMIN_USER_EMAIL}    ${UI_ADMIN_USER_PASSWORD}
    ELSE IF  '${role}' == 'ROLE_MANAGER'
        RETURN    ${UI_MANAGER_USER_EMAIL}  ${UI_MANAGER_USER_PASSWORD}
    ELSE IF  '${role}' == 'ROLE_USER'
        RETURN    ${UI_REGULAR_USER_EMAIL}  ${UI_REGULAR_USER_PASSWORD}
    ELSE IF  '${role}' == 'ROLE_SECRET_PROJECT'
        RETURN    ${UI_SECRET_PROJECT_USER_EMAIL}    ${UI_SECRET_PROJECT_USER_PASSWORD}
    END

Get Random Predefined User
    ${user_role} =     Evaluate    random.choice(['ROLE_SECRET_PROJECT', 'ROLE_ADMIN', 'ROLE_MANAGER', 'ROLE_USER'])
    ${email}    ${password} =      Get Predefined User Creds    ${user_role}
    RETURN    ${email}    ${password}

Management Page is Loaded
    ManagementPage.Verify Page Loaded

Login Page is Loaded
    LoginPage.Verify Page Loaded

Message Dialog Opened
    [Arguments]    ${title}    ${message}=${EMPTY}
    Wait Until Element Is Visible    xpath=//mat-dialog-container[//h1[.="${title}"] and //div[contains(., "${message}")]]
    Wait Until Element Is Visible    ${MSG_DIALOG_OK_BTN}

Close Message Dialog
    Click Element                ${MSG_DIALOG_OK_BTN}
    Page Should Not Contain      ${MSG_DIALOG_OK_BTN}

Open User Profile
    Click Element    ${MAIN_MENU_PROFILE_BTN}
    UserProfileDialog.Verify Dialog is Opened

Open Users Page
    Click Element    ${MAIN_MENU_USERS_BTN}
    Users Page Is Opened

Open Grazing Page
    Click Element    ${MAIN_MENU_GRAZING_BTN}
    Click Element At Coordinates    ${MAP_WINDOW}    0    0    # Hide main side menu
    Verify Grazing Page Is Loaded

Skip Test If Browser Name Is
    [Arguments]        ${skip_browser_name}
    ${browser_name} =  Get Current Browser Name
    Skip If    ${{$browser_name.lower() == $skip_browser_name}}        Test skipped as current WebDriver = ${browser_name}"
