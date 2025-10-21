*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=276832&suiteId=279308

Resource          ../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource          ../../../../resources/ui/HerdManagerApp.robot

Test Setup        Open Browser On Login Page
Test Teardown     End Web Test

Test Tags         Negative

*** Test Cases ***
Select grazing data with invalid date in selecting dates (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/282157
    [Tags]             TC282157    safari_skip
    # Pre-Setup
    Skip Test If Browser Name Is    skip_browser_name=safari
    ${timezone} =           Set Variable    UTC
 
    # Create farm
    Create API Session With Common Enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_resp} =          Create Farm Common   ${enterprise_id}    timeZone=${timezone}
    ${farm_id} =            Set Variable         ${farm_resp.json()}[id]
    # Create user
    ${password}     ${user_resp} =    Create User With Password Common    ${farm_id}
    ...                                                                   role=ROLE_USER
    ...                                                                   timeView=FARM_TIME_VIEW
    ${email} =              Set Variable         ${user_resp.json()}[username]
    Disable Password Change Request in DB        ${user_resp.json()}[id]

    # Create herd
    ${create_herd} =        Create New Herd      farm_id=${farm_id}
    ${herd_id} =            Set Variable         ${create_herd.json()}[id]
    
    # Test
    UI User Login           ${email}             ${password}
    Open Grazing Page    
    # Select herd
    Click Select Grazing Data Button
    Select Herd In Grazing List    ${herd_id}
    Click Next In Grazing Dialog

    # Select collars
    Check Collars Selection Is Available
    Set "Use all collars"
    Click Next In Grazing Dialog

    # Select date
    ${start_timestamp} =           Evaluate     int(time.time())*1000+86400000  # One day
    ${incorrect_end_timestamp} =   Evaluate     ${start_timestamp}+31643326000  # One year one day
    ${correct_end_timestamp} =     Evaluate     ${start_timestamp}+31536000000  # One year
    ${start_datetime} =            Evaluate     datetime.datetime.fromtimestamp(${start_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m%d00%Y%I%M%p")
    ${incorrect_end_datetime} =    Evaluate     datetime.datetime.fromtimestamp(${incorrect_end_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m%d00%Y%I%M%p")
    ${os_platform} =               Evaluate     platform.system()
    IF  "${os_platform}"=="Windows"
        ${correct_end_datetime_msg} =  Evaluate     datetime.datetime.fromtimestamp(${correct_end_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m/%d/%Y %#I:%M %p %Z")
    ELSE
        ${correct_end_datetime_msg} =  Evaluate     datetime.datetime.fromtimestamp(${correct_end_timestamp}/1000, tz=datetime.timezone.utc).strftime("%m/%d/%Y %-I:%M %p %Z")
    END
    
    Select Grazing From Date    ${start_datetime}
    Select Grazing To Date      ${incorrect_end_datetime}

    Check Date Error Message    From    (from must be in the past)
    Check Date Error Message    To      (Maximum is ${correct_end_datetime_msg} and not allow to proceed)
    
Select grazing data without selecting herd (ROLE_USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/282152
    [Tags]             TC282152
    # Pre-Setup
    # Create farm
    Create API Session With Common Enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_resp} =          Create Farm Common   ${enterprise_id}    timeZone=GMT
    ${farm_id} =            Set Variable         ${farm_resp.json()}[id]
    # Create user
    ${password}     ${user_resp} =    Create User With Password Common    ${farm_id}    role=ROLE_USER    
    ${email} =              Set Variable         ${user_resp.json()}[username]
    Disable Password Change Request in DB        ${user_resp.json()}[id]

    # Create herd
    ${create_herd} =        Create New Herd      farm_id=${farm_id}
    ${herd_id} =            Set Variable         ${create_herd.json()}[id]
    
    # Test
    UI User Login           ${email}             ${password}
    Open Grazing Page
    Click Select Grazing Data Button
    
    Element Should Be Disabled    ${GRAZING_DATA_DIALOG_NEXT_BTN}
