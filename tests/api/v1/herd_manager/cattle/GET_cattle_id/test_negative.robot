*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248591

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/farm.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/enterprise.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         GET    Negative

*** Test Cases ***
Get cattle by not existing id (ROLE_MANAGER) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248597
    [Tags]           TC248597
    # Pre-setup
    ${cattle_id} =   Generate UUID

    # Use manager user for API calls
    ${users} =             Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_MANAGER][token]

    # Test
    ${response} =          Get Cattle By ID     ${cattle_id}     expected_status=404
    Should Be Equal As Strings    ${response.json()}[message]    CATTLE_NOT_FOUND_BY_ID    Error message is not equal to expected. Actual: '${response.json()}[message]'. Expected: CATTLE_NOT_FOUND_BY_ID
    List Should Contain Value     ${response.json()}[values]     ${cattle_id}              Cattle id '${cattle_id}' is not in values list.

Get cattle from another enterprise (ROLE_ADMIN) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248608
    [Tags]           TC248608
    # Pre-setup
    # Create cattle in farm A
    ${farmA_id} =           Get Common Farm Id
    Create New Cattle       ${farmA_id}

    # Create cattle in farm B
    ${enterprise_create} =   Create Enterprise
    ${enterpriseA_id} =      Set Variable                  ${enterprise_create.json()}[id]
    ${farmB_resp} =          Create New Farm               ${enterpriseA_id}
    ${farmB_id} =            Set Variable                  ${farmB_resp.json()}[id]
    ${createB_response} =    Create New Cattle             ${farmB_id}
    ${cattleB_id} =          Set Variable                  ${createB_response.json()}[id]
    
    # Use admin user for API calls
    ${users} =               Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_ADMIN][token]

    ${response} =            Get Cattle By ID              ${cattleB_id}    expected_status=403
    Should Be Equal As Strings    ${response.json()}[message]    Access is denied    Error message is not equal to expected. Actual: '${response.json()}[message]'. Expected: Access is denied


Get cattle from other farm in enterprise (ROLE_MANAGER/USER) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248610
    [Tags]           TC248610
    # Pre-setup
    # Create cattle in farm A
    ${farmA_id} =           Get Common Farm Id
    Create New Cattle       ${farmA_id}

    # Create cattle in farm B    
    ${enterprise_id} =       Get Common Enterprise Id
    ${farmB_resp} =          Create New Farm               ${enterprise_id}
    ${farmB_id} =            Set Variable                  ${farmB_resp.json()}[id]
    ${createB_response} =    Create New Cattle             ${farmB_id}
    ${cattleB_id} =          Set Variable                  ${createB_response.json()}[id]
    
    # Use regular/manager user for API calls
    ${users} =               Get Common Users
    ${role} =                Evaluate                      random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    Use Specific User For API Calls                        user_token=${users}[${role}][token]

    ${response} =            Get Cattle By ID              ${cattleB_id}    expected_status=403
    Should Be Equal As Strings    ${response.json()}[message]    Access is denied    Error message is not equal to expected. Actual: '${response.json()}[message]'. Expected: Access is denied
