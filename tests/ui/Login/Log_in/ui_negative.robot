*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=276896

Library           String

Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser On Login Page
Test Teardown     End Web Test

Test Tags         Negative

*** Test Cases ***
Log in with invalid credentials
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276894
    [Tags]             TC276894
    
    ${random_email} =     Generate Random String
    Fill "Email" Field    ${random_email}@SECRET_PROJECT.io
    Check "Login" Button is Inactive And Click
    Login Page is Loaded

    ${random_password} =    Evaluate    random.choice(["${SPACE}", "NULL", "null", "123"])
    Fill "Password" Field   ${random_password}
    Click "Login" Button
    Message Dialog Opened   Invalid Username or Password
    Close Message Dialog

Too many attempts block
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276898
    [Tags]             TC276898
    # Pre-Setup
    # Create user
    Create API Session With Common Farm
    ${farm_id} =            Get Common Farm Id
    ${correct_password}     ${user_resp} =    Create User With Password Common    ${farm_id}
    ${email} =              Set Variable      ${user_resp.json()}[username]
    ${random_password} =    Generate Random String

    # Test
    Fill "Email" Field      ${email}

    FOR    ${i}    IN RANGE    3
        Fill "Password" Field   ${random_password}
        Click "Login" Button
        Message Dialog Opened   Invalid Username or Password
        Close Message Dialog
        Sleep  1
    END

    Fill "Password" Field   ${random_password}
    Click "Login" Button
    Message Dialog Opened   Login locked    There have been too many failed login attempts. Wait
    Close Message Dialog

    Fill "Password" Field   ${correct_password}
    Click "Login" Button
    Message Dialog Opened   Login locked
