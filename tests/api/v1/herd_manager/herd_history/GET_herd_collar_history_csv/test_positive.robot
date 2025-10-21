*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=268360

Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/paddock.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd_history.robot

Suite Setup      Run Only Once       Create API Session With Common Users
Suite Teardown   Clean Up

Test Tags        GET    Positive

*** Test Cases ***
Retrieve history in CSV file for all herds (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/258724
    [Tags]           TC258724
    Skip    Bug https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/306378
    # Pre-Setup
    ${from_datetime} =       Evaluate                          int(time.time()*1000)
    ${farm_id} =             Get Common Farm Id
    ${farm_response} =       Get Farm By ID                    ${farm_id}
    ${timeZone} =            Set Variable                      ${farm_response.json()}[timeZone]

    # Create herd with collar
    ${create_herd} =         Create New Herd                   farm_id=${farm_id}
    ${herd_id} =             Set Variable                      ${create_herd.json()}[id]
    ${herd_name} =           Set Variable                      ${create_herd.json()}[name]
    # Create paddock
    ${create_paddock} =      Create New Paddock                farm_id=${farm_id}
    ${paddock_id} =          Set Variable                      ${create_paddock.json()}[id]
    ${paddocks_list} =       Create List                       ${paddock_id}
    # Assign paddock to herd    
    ${herd_slots} =          Create Herd Slots                 paddock_ids=${paddocks_list}    date=${from_datetime}
    Update Herd By Id        herd_id=${herd_id}                slots=${herd_slots}
    Wait Herd Progress Completed    ${herd_id}

    # Test
    # Use ROLE_USER
    ${users} =               Get Common Users
    Use Specific User For API Calls                            user_token=${users}[ROLE_USER][token]
    ${to_datetime} =         Evaluate                          int(time.time()*1000)

    ${response} =            Get Collar History In CSV         from=${from_datetime}    to=${to_datetime}    timeZone=${timeZone}
    # Check header
    Should Be Equal          ${response.headers}[Content-Disposition]    attachment; filename="my-csv-file.csv"    header 'Content-Disposition' is not equal to expected. Actual: ${response.headers}[Content-Disposition]. Expected: attachment; filename="my-csv-file.csv"
    # Check lines count
    ${lines_count} =         Get Line Count    ${response.text}
    Should Be True           ${lines_count}>1  Should be at least 2 lines in response. Actual: ${lines_count}
    # Check "Edit Slot" action is presented
    Should Contain           ${response.text}  Edit Slot       Response doesn't contain action 'Edit Slot'. Response text: ${response.text}
    # Check created herd name is presented
    Should Contain           ${response.text}  ${herd_name}    Response doesn't contain created herd name. Expected name: ${herd_name}. Response text: ${response.text}
    # Check CSV headers
    ${lines} =               Split To Lines    ${response.text}
    ${actual_headers} =      Split String      ${lines}[0]    ,
    ${expected_headers} =    Create List       "Herd"
    ...                                        "Calendar Description"
    ...                                        "Action"
    ...                                        "Date of Edit or Action"
    ...                                        "SECRET_PROJECT"
    ...                                        "Immediate Action"
    ...                                        "Timed Action 1"
    ...                                        "TA1 Date"
    ...                                        "Timed Action 2"
    ...                                        "TA2 Date"
    ...                                        "Timed Action 3"
    ...                                        "TA3 Date"
    ...                                        "Timed Action 4"
    ...                                        "TA4 Date"
    Lists Should Be Equal    ${actual_headers}    ${expected_headers}  CSV headers are not equal to expected. Actual: ${actual_headers}. Expected: ${expected_headers}    
    # Check datetime
    ${values_lines} =                   Get Slice From List  ${lines}    start=${1}
    # Adjusting "from" and "to" datetimes to timezones
    ${from_datetime_adjusted} =         Adjust Unix Time     ${from_datetime}    ${timeZone}
    ${to_datetime_adjusted} =           Adjust Unix Time     ${to_datetime}      ${timeZone}
    FOR    ${line}    IN     @{values_lines}
        ${values} =                     Split String  ${line}  ,
        # Convert date value from received csv response to datetime object, adding UTC time zone, converting to UNIX time format in milliseconds
        ${response_datetime_value} =    Evaluate         int(datetime.datetime.strptime(${values}[3], "%m/%d/%Y %I:%M:%S.%f %p").replace(tzinfo=datetime.timezone.utc).timestamp() * 1000)
        ${date_is_ok} =                 Evaluate         (${response_datetime_value}>=${from_datetime_adjusted} and ${response_datetime_value}<=${to_datetime_adjusted})
        Should Be True                  ${date_is_ok}    'Date of Edit or Action' ${values}[3] is not in expected period. Actual value: ${response_datetime_value}. Period: from ${from_datetime} to ${to_datetime}
    END
