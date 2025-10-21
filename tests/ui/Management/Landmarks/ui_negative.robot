*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=276870

Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser And Login
Test Teardown     End Web Test

Test Tags         Negative

*** Test Cases ***
Landmark empty and NULL name (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276455
    [Tags]             TC276455    role:ROLE_USER
    # Prepare data
    ${landmark_type} =         Evaluate        random.choice(${POINT_LANDMARKS_UI})
    ${landmark_type_name} =    Set Variable    ${landmark_type}[name]
    ${landmark_type_button} =  Set Variable    ${landmark_type}[button]

    # Test
    Click "Create Landmark"
    Choose Landmark Type       ${landmark_type_button}
    ${coords} =                Generate Landmark Coords   1

    Click UI Coords On Map     ${coords}
    Click "Save" Landmark
    Verify Landmark Info Form Is Opened

    Enter Landmark Name        ${SPACE}
    Save Landmark Info
    Message Dialog Opened    title=Conflict Saving    message=Cannot save due to an error (name: Landmark name can't be empty). Please correct the error and retry.
    Close Message Dialog

    Clear Landmark Name
    Enter Landmark Name        NULL
    Save Landmark Info
    Message Dialog Opened    title=Conflict Saving    message=Cannot save due to an error (name: Landmark name can't be 'null' string). Please correct the error and retry.
