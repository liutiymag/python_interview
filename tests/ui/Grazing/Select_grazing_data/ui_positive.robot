*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=279308

Resource          ../../../../resources/api/Keywords/GrazingAPI/collar_history.robot
Resource          ../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource          ../../../../resources/api/Keywords/HerdManagerAPI/landmark.robot
Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser On Login Page
Test Teardown     End Web Test

Test Tags         Positive

*** Test Cases ***
Select grazing data (ROLE_ADMIN)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/279306
    [Tags]             TC279306    Smoke    safari_skip
    # Pre-Setup
    Skip Test If Browser Name Is    skip_browser_name=safari
    Skip            https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/319072
    # Create farm
    Create API Session With Common Enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_resp} =          Create Farm Common   ${enterprise_id}    timeZone=GMT
    ${farm_id} =            Set Variable         ${farm_resp.json()}[id]
    ${farm_coords} =        Set Variable         ${farm_resp.json()}[location][coordinates]
    # Create ADMIN user
    ${password}     ${user_resp} =    Create User With Password Common    ${farm_id}    role=ROLE_ADMIN    
    ${email} =              Set Variable         ${user_resp.json()}[username]
    Disable Password Change Request in DB        ${user_resp.json()}[id]

    # Create collars
    ${collarIds} =          Create List
    FOR  ${index}  IN RANGE  2
        &{collar_info} =    Create New Collar Via Simulator    ${farm_id}  latitude=${farm_coords}[1]  longitude=${farm_coords}[0]
        Append To List      ${collarIds}         ${collar_info}[dbId]
    END

    # Create herd
    ${create_herd} =        Create New Herd      farm_id=${farm_id}    collarIds=${collarIds}
    ${herd_id} =            Set Variable         ${create_herd.json()}[id]
    
    # Create landmark
    UI User Login           ${email}             ${password}
    ${landmark_name} =      Generate Random String   128
    Create Landmark in UI   ${landmark_name}     AREA_LANDMARKS

    # Generate grazing data
    ${landmark_id} =        Get Landmark ID By Name    ${farm_id}    ${landmark_name}
    ${start_timestamp} =    Evaluate             int(time.time())*1000-86400000  # One day
    ${end_timestamp} =      Evaluate             int(time.time())*1000    
    Generate Grazing By Landmark    ${herd_id}   ${landmark_id}    total_points=${2000}    start_date=${start_timestamp}    end_date=${end_timestamp}
     
    # Test    
    # Make screenshot of clear grazing map
    Open Grazing Page    
    ${map_without_grazing_path} =    Set Variable    ${OUTPUTDIR}/map_without_grazing.png
    Make Map Screenshot              ${map_without_grazing_path}
    
    # Turn on grazing
    # Select herd
    Click Select Grazing Data Button
    Select Herd In Grazing List    ${herd_id}
    Click Next In Grazing Dialog

    # Select collars
    Check Collars Selection Is Available
    Set "Use all collars"
    Click Next In Grazing Dialog

    # Select date
    ${start_datetime} =    Evaluate    datetime.datetime.fromtimestamp(${start_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m%d00%Y%I%M%p")
    ${end_datetime} =      Evaluate    datetime.datetime.fromtimestamp(${end_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m%d00%Y%I%M%p")
    Select Grazing From Date           ${start_datetime}
    Select Grazing To Date             ${end_datetime}

    Click Ok Button On Grazing Select
    Capture Page Screenshot
    Wait For Grazing Is Displayed
    # Make screenshot with grazing
    ${map_with_grazing_path} =    Set Variable    ${OUTPUTDIR}/map_with_grazing.png
    Make Map Screenshot           ${map_with_grazing_path}
    Capture Page Screenshot
    # Compare images
    ${grazing_is_present} =       Check If Grazing Is Displayed    ${map_without_grazing_path}    ${map_with_grazing_path}
    Should Be True    ${grazing_is_present}    Grazing is not present on the map
