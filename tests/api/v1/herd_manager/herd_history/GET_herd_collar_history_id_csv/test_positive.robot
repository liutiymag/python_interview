*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=268364

Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd_history.robot

Suite Setup      Run Only Once       Create API Session With Common Users
Suite Teardown   Clean Up

Test Tags        GET    Positive

*** Test Cases ***
Retreive history in CSV file (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/258702
    [Tags]           TC258702
    # Pre-Setup
    ${farm_id} =             Get Common Farm Id
    # Create herd with collar
    ${create_herd} =         Create New Herd                   farm_id=${farm_id}
    ${herd_id} =             Set Variable                      ${create_herd.json()}[id]
    # Get id of the record in the herd_collar_history DB table
    ${db_records} =          Get Collar History From DB By Herd Id    ${herd_id}
    ${history_id} =          Set Variable                      ${db_records}[0][0]

    # Test
    # Use ROLE_USER
    ${users} =                 Get Common Users
    Use Specific User For API Calls                              user_token=${users}[ROLE_USER][token]
    ${response} =              Get Collar History By Id In CSV   ${history_id}
    # Check header
    Should Be Equal            ${response.headers}[Content-Disposition]    attachment; filename="my-csv-file.csv"    header 'Content-Disposition' is not equal to expected. Actual: ${response.headers}[Content-Disposition]. Expected: attachment; filename="my-csv-file.csv"
    # Check lines count
    ${lines_count} =           Get Line Count    ${response.text}
    Should Be True             ${lines_count}>1  Should be at least 2 lines in response. Actual: ${lines_count}
    # Check CSV headers
    ${lines} =                 Split To Lines    ${response.text}
    ${actual_field_names} =    Split String      ${lines}[0]    ,
    ${expected_field_names} =  Create List       "DeviceEUI"
    ...                                          "EarTag"
    ...                                          "SoundEnabled"
    ...                                          "ShockEnabled"
    ...                                          "SynchronizationState"
    ...                                          "TrackingState"
    ...                                          "ManagementState"
    ...                                          "ProtocolVersion"
    ...                                          "HerdName"
    ...                                          "Latitude"
    ...                                          "Longitude"
    ...                                          "CollarId"
    List Should Contain Sub List      ${actual_field_names}    ${expected_field_names}  CSV headers are not equal to expected. Actual: ${actual_field_names}. Expected: ${expected_field_names}
