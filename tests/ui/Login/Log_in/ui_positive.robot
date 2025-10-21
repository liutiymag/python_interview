*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=276896

Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser On Login Page
Test Teardown     End Web Test

Test Tags         Positive

*** Test Cases ***
Log in with valid credentials with different users
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276875
    [Tags]             TC276875
    
    ${email}  ${password} =  Get Random Predefined User
    
    UI User Login  ${email}  ${password}
    