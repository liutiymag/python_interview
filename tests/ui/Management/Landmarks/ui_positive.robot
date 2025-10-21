*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=276870

Library           String

Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser And Login
Test Teardown     End Web Test

Test Tags         Positive

*** Test Cases ***
Create a Landmark of Point Type (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276386
    [Tags]             TC276386    role:ROLE_USER
    # Prepare data
    ${landmark_type} =         Evaluate        random.choice(${POINT_LANDMARKS_UI})
    ${landmark_type_name} =    Set Variable    ${landmark_type}[name]
    ${landmark_type_button} =  Set Variable    ${landmark_type}[button]
    ${landmark_name} =         Generate Random String   128
    
    # Test
    Click "Create Landmark"
    Choose Landmark Type       ${landmark_type_button}
    ${coords} =                Generate Landmark Coords   1
    
    Click UI Coords On Map     ${coords}
    Click "Save" Landmark
    Verify Landmark Info Form Is Opened
    Verify Landmark Type Name  ${landmark_type_name}
    Enter Landmark Name        ${landmark_name}
    Save Landmark Info
    Verify Landmark Info Form Is Closed
    Verify Tools Panel Is Present
    
    [Teardown]    Run Keywords    Delete Landmark From Context Menu    @{coords}[0]
    ...                    AND    End Web Test

Create a Landmark of Line Type (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276427
    [Tags]             TC276427    role:ROLE_USER
    # Prepare data
    ${landmark_type} =         Evaluate        random.choice(${LINE_LANDMARKS_UI})
    ${landmark_type_name} =    Set Variable    ${landmark_type}[name]
    ${landmark_type_button} =  Set Variable    ${landmark_type}[button]
    ${points_number} =         Evaluate        random.randint(2, 7)
    ${landmark_name} =         Generate Random String   128
    
    # Test
    Click "Create Landmark"
    Choose Landmark Type        ${landmark_type_button}
    ${coords} =    Generate Landmark Coords   ${points_number}

    Click UI Coords On Map      ${coords}    click_type=double_click
    Click "Save" Landmark
    Verify Landmark Info Form Is Opened
    Verify Landmark Type Name   ${landmark_type_name}
    Enter Landmark Name         ${landmark_name}
    Save Landmark Info
    Verify Landmark Info Form Is Closed
    Verify Tools Panel Is Present
    
    [Teardown]    Run Keywords    Delete Landmark From Context Menu    @{coords}[0]
    ...                    AND    End Web Test

Create a Landmark of Area Type (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/276437
    [Tags]             TC276437    role:ROLE_USER
    # Prepare data
    ${landmark_type} =         Evaluate        random.choice(${AREA_LANDMARKS_UI})
    ${landmark_type_name} =    Set Variable    ${landmark_type}[name]
    ${landmark_type_button} =  Set Variable    ${landmark_type}[button]
    ${points_number} =         Evaluate        random.randint(7, 15)
    ${landmark_name} =         Generate Random String   128
    
    # Test
    Click "Create Landmark"
    Choose Landmark Type        ${landmark_type_button}
    ${coords} =    Generate Landmark Coords   ${points_number}    is_polygon=${True}

    Click UI Coords On Map      ${coords}
    Click "Save" Landmark
    Verify Landmark Info Form Is Opened
    Verify Landmark Type Name   ${landmark_type_name}
    Enter Landmark Name         ${landmark_name}
    Save Landmark Info
    Verify Landmark Info Form Is Closed
    Verify Tools Panel Is Present

    [Teardown]    Run Keywords    Delete Landmark From Context Menu    map_center=${True}
    ...                    AND    End Web Test
