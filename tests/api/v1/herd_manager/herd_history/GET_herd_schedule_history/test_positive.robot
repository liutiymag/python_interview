*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=268366

Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/paddock.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd_history.robot

Suite Setup      Run Only Once       Create API Session With Common Users
Suite Teardown   Clean Up

Test Tags        GET    Positive

*** Test Cases ***
Retrieve herd scheduled history by farmId (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/257174
    [Tags]           TC257174
    # Pre-Setup
    ${farm_id} =             Get Common Farm Id
    # Create herd with collar
    ${create_herd} =         Create New Herd              farm_id=${farm_id}
    ${herd_id} =             Set Variable                 ${create_herd.json()}[id]
    # Create paddock
    ${create_paddock} =      Create New Paddock           farm_id=${farm_id}
    ${paddock_id} =          Set Variable                 ${create_paddock.json()}[id]
    ${paddocks_list} =       Create List                  ${paddock_id}
    # Assign paddock to herd
    ${datetime} =            Evaluate                     int(time.time())+100000    # current datetime + 100 seconds
    ${herd_slots} =          Create Herd Slots            paddock_ids=${paddocks_list}    date=${datetime}
    Update Herd By Id        herd_id=${create_herd.json()}[id]    slots=${herd_slots}

    # Test
    # Use ROLE_USER
    ${users} =               Get Common Users
    Use Specific User For API Calls                       user_token=${users}[ROLE_USER][token]
    ${response} =            Get Herd Schedule History    farmId=${farm_id}
    # Search herd and check fields
    ${herd_is_found} =    Set Variable    ${False}
    FOR  ${record}  IN  @{response.json()}
        IF    '${record}[herdId]'=='${herd_id}'
            ${herd_is_found} =           Set Variable    ${True}
            ${SECRET_PROJECT_activate_found} =    Set Variable    ${False}
            FOR  ${entry}  IN  @{record}[detail][entries]
                IF  '${entry}[action]'=='SECRET_PROJECT_ACTIVATE'                    
                    ${SECRET_PROJECT_activate_found} =    Set Variable    ${True}
                    Should Be Equal     ${entry}[when]           ${datetime}     'when' is not equal to expected. Actual: ${entry}[when]. Expected: ${datetime}
                    Should Be Equal     ${entry}[newPaddockId]   ${paddock_id}   'newPaddockId' is not equal to expected. Actual: ${entry}[newPaddockId]. Expected: ${paddock_id}
                END
            END
            Should Be True    ${SECRET_PROJECT_activate_found}    SECRET_PROJECT_ACTIVATE is not found in schedule history
        END
    END
    Should Be True    ${herd_is_found}    herd is not found in schedule history. herdId: ${herd_id}
