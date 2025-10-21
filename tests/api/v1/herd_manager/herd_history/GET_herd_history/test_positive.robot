*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=268367

Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd_history.robot

Suite Setup      Run Only Once       Create API Session With Common Users
Suite Teardown   Clean Up

Test Tags        GET    Positive

*** Test Cases ***
Retrieve herd history by farmId (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/257173
    [Tags]           TC257173
    # Pre-Setup
    ${farm_id} =             Get Common Farm Id
    # Create herd with collar
    ${create_herd} =         Create New Herd              farm_id=${farm_id}
    ${herd_id} =             Set Variable                 ${create_herd.json()}[id]

    # Test
    # Use ROLE_USER
    ${users} =               Get Common Users
    Use Specific User For API Calls                       user_token=${users}[ROLE_USER][token]
    # Get herd history
    ${response} =            Get Herd History             farmId=${farm_id}
    # Check herd is present in response
    ${response_herd_ids} =   Evaluate                     [i['herdId'] for i in ${response.json()}]
    List Should Contain Value    ${response_herd_ids}     ${herd_id}    herd is missed in response. Expected herdId: ${herd_id}. Actual ids: ${response_herd_ids}
    # Search herd and check fields
    FOR  ${record}  IN  @{response.json()}
        IF    '${record}[herdId]'=='${herd_id}'
            # Date diff should be less than 1 second
            ${datetime_diff} =  Evaluate    abs(${record}[createDate]-${create_herd.json()}[modifyDate])
            Should Be True     ${datetime_diff}<1000    time difference is more than 1 second. Value: ${datetime_diff} ms
            Should Be Equal    ${record}[name]          ${create_herd.json()}[name]          'name' is not equal to expected. Actual: ${record}[name]. Expected: ${create_herd.json()}[name]
            Should Be Equal    ${record}[count]         ${1}                                 'count' is not equal to expected. Actual: ${record}[count]. Expected: 1
            Should Be Equal    ${record}[operation]     CREATE                               'operation' is not equal to expected. Actual: ${record}[operation]. Expected: CREATE
        END
    END
