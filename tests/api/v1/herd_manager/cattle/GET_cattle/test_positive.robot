*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248397

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/enterprise.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         GET    Positive

*** Test Cases ***
Get all cattles in the system (ROLE_SECRET_PROJECT)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248399
    [Tags]           TC248399
    # Pre-setup
    # Create enterprise and farm
    ${enterprise_create} =  Create Enterprise
    ${enterprise_id} =      Set Variable                 ${enterprise_create.json()}[id]
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    
    # Create new cattle
    ${create_cattle_1} =    Create New Cattle            ${farm_id}
    ${cattle_1_id} =        Set Variable                 ${create_cattle_1.json()}[id]
    ${cattle_1_earTag} =    Set Variable                 ${create_cattle_1.json()}[earTag]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${create_cattle_2} =    Create New Cattle            ${common_farm_id}
    ${cattle_2_id} =        Set Variable                 ${create_cattle_2.json()}[id]
    ${cattle_2_earTag} =    Set Variable                 ${create_cattle_2.json()}[earTag]

    # Test
    ${response} =           Get Cattles
    ${cattles_info} =       Set Variable                 ${response.json()}
    # List length should be >=2
    ${cattles_number}       Evaluate                     len(${cattles_info})
    Should Be True          ${cattles_number}>=2         Cattles list should contain >=2 items. Actual: ${cattles_number}
    
    # Check both cattles are in list    
    ${cattles_count} =      Set Variable                 ${0}    
    FOR  ${cattle}  IN  @{cattles_info}
        IF  '${cattle}[id]'=='${cattle_1_id}' and '${cattle}[earTag]'=='${cattle_1_earTag}'
            ${cattles_count} =    Set Variable    ${cattles_count}+1
        END
        IF  '${cattle}[id]'=='${cattle_2_id}' and '${cattle}[earTag]'=='${cattle_2_earTag}'
            ${cattles_count} =    Set Variable    ${cattles_count}+1
        END
    END
    # Check cattle1 and cattle2 are found in list
    Should Be True          ${cattles_count}==2         Cattles list should contain 2 items. Actual: ${cattles_count}    

Get all cattles in the enterprise (ROLE_SECRET_PROJECT) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248406
    [Tags]           TC248406
    # Pre-setup
    # Create enterprise
    ${enterprise_create} =  Create Enterprise
    ${enterprise_id} =      Set Variable                 ${enterprise_create.json()}[id]
    # Create farm
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]
    # create cattle2
    ${cattle2_create} =     Create New Cattle            ${farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle3_create} =     Create New Cattle            ${common_farm_id}
    ${cattle3_id} =         Set Variable                 ${cattle3_create.json()}[id]
    
    # Test
    # Get cattles from enterprise
    ${cattles_resp} =       Get Cattles                  enterpriseId=${enterprise_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Check cattle1 and cattle2 exist in cattles list
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle3 id not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle3_id}    Cattle id '${cattle3_id}' should not exist in cattles list. Actual: ${catlles_ids}

Get all cattles in the farm (ROLE_SECRET_PROJECT) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248412
    [Tags]           TC248412
    # Pre-setup
    # Create enterprise
    ${enterprise_create} =  Create Enterprise
    ${enterprise_id} =      Set Variable                 ${enterprise_create.json()}[id]
    # Create farm
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]
    # create cattle2
    ${cattle2_create} =     Create New Cattle            ${farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle3_create} =     Create New Cattle            ${common_farm_id}
    ${cattle3_id} =         Set Variable                 ${cattle3_create.json()}[id]
    
    # Test
    # Get cattles from farm
    ${cattles_resp} =       Get Cattles                  farmId=${farm_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Check cattle1 and cattle2 exist in cattles list
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle3 id not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle3_id}    Cattle id '${cattle3_id}' should not exist in cattles list. Actual: ${catlles_ids}
    
Get cattles from the specific farm in the enterprise (ROLE_SECRET_PROJECT) 
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248414
    [Tags]             TC248414
    # Pre-setup
    # Create farm in common enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]
    # create cattle2
    ${cattle2_create} =     Create New Cattle            ${farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle3_create} =     Create New Cattle            ${common_farm_id}
    ${cattle3_id} =         Set Variable                 ${cattle3_create.json()}[id]
    
    # Test
    # Get cattles from farm
    ${cattles_resp} =       Get Cattles                  enterpriseId=${enterprise_id}    farmId=${farm_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Check cattle1 and cattle2 exist in cattles list
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle3 id not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle3_id}    Cattle id '${cattle3_id}' should not exist in cattles list. Actual: ${catlles_ids}

Get cattles from the specific farm in the enterprise (ROLE_ADMIN)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248455
    [Tags]             TC248455
    # Pre-setup
    # Create farm in common enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]
    # create cattle2
    ${cattle2_create} =     Create New Cattle            ${farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle3_create} =     Create New Cattle            ${common_farm_id}
    ${cattle3_id} =         Set Variable                 ${cattle3_create.json()}[id]
    
    # Test
    # Use admin user
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[ROLE_ADMIN][token]
    # Get cattles from farm
    ${cattles_resp} =       Get Cattles                  enterpriseId=${enterprise_id}    farmId=${farm_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Check only cattle3 exists in cattles list
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id is not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should not exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id is not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should not exist in cattles list. Actual: ${catlles_ids}
    # Check cattle3 id is in list
    List Should Contain Value          ${catlles_ids}    ${cattle3_id}    Cattle id '${cattle3_id}' should exist in cattles list. Actual: ${catlles_ids}

Get cattles from the enterprise (ROLE_ADMIN)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248470
    [Tags]             TC248470
    # Pre-setup
    # Create enterprise
    ${enterprise_create} =  Create Enterprise
    ${new_enterprise_id} =  Set Variable                 ${enterprise_create.json()}[id]
    # Create farm
    ${new_farm_create} =    Create New Farm              enterprise_id=${new_enterprise_id}
    ${new_farm_id} =        Set Variable                 ${new_farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${new_farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]

    # Create farm in common enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # create cattle2
    ${cattle2_create} =     Create New Cattle            ${farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle3_create} =     Create New Cattle            ${common_farm_id}
    ${cattle3_id} =         Set Variable                 ${cattle3_create.json()}[id]
    
    # Test
    # Use admin user
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[ROLE_ADMIN][token]
    # Get cattles from common enterprise
    ${cattles_resp} =       Get Cattles                  enterpriseId=${enterprise_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Check only cattle3 exists in cattles list
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id is not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should not exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id is in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}
    # Check cattle3 id is in list
    List Should Contain Value          ${catlles_ids}    ${cattle3_id}    Cattle id '${cattle3_id}' should exist in cattles list. Actual: ${catlles_ids}

Get cattles from the enterprise (ROLE_USER/MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248478
    [Tags]             TC248478    Smoke
    # Pre-setup
    # Create farm in common enterprise
    ${enterprise_id} =      Get Common Enterprise Id
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create cattle1
    ${cattle1_create} =     Create New Cattle            ${farm_id}
    ${cattle1_id} =         Set Variable                 ${cattle1_create.json()}[id]

    # Create cattle in common farm
    ${common_farm_id} =     Get Common Farm Id
    ${cattle2_create} =     Create New Cattle            ${common_farm_id}
    ${cattle2_id} =         Set Variable                 ${cattle2_create.json()}[id]
    
    # Test
    # Use regular/manager user
    ${role} =               Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[${role}][token]
    # Get cattles from common enterprise
    ${cattles_resp} =       Get Cattles                  enterpriseId=${enterprise_id}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id is not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should not exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id is in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}

Get the cattle by status(ROLE_USER/MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248479
    [Tags]             TC248479
    # Pre-setup
    # Create cattle in common farm
    ${common_farm_id} =      Get Common Farm Id
    ${cattle1_create} =      Create New Cattle            ${common_farm_id}
    ${cattle_active_id} =    Set Variable                 ${cattle1_create.json()}[id]
    # Create cattle2 and make it INACTIVE
    ${cattle2_create} =      Create New Cattle            ${common_farm_id}
    ${cattle_inactive_id} =  Set Variable                 ${cattle2_create.json()}[id]
    Update Cattle            ${cattle_inactive_id}        status=INACTIVE
    
    # Test
    # Choose status randomly
    ${status} =             Evaluate                     random.choice(['ACTIVE', 'INACTIVE'])
    # Use regular/manager user
    ${role} =               Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[${role}][token]
    # Get cattles by status
    ${cattles_resp} =       Get Cattles                  status=${status}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    IF  '${status}' == 'ACTIVE'
        # Check cattle_active_id is in list
        List Should Contain Value          ${catlles_ids}    ${cattle_active_id}    Cattle id '${cattle_active_id}' should exist in cattles list. Actual: ${catlles_ids}
        # Check cattle_inactive_id is not in list
        List Should Not Contain Value      ${catlles_ids}    ${cattle_inactive_id}  Cattle id '${cattle_inactive_id}' should not exist in cattles list. Actual: ${catlles_ids}
    ELSE
        # Check cattle_active_id id is not in list
        List Should Not Contain Value      ${catlles_ids}    ${cattle_active_id}    Cattle id '${cattle_active_id}' should not exist in cattles list. Actual: ${catlles_ids}
        # Check cattle_inactive_id id is in list
        List Should Contain Value          ${catlles_ids}    ${cattle_inactive_id}  Cattle id '${cattle_inactive_id}' should exist in cattles list. Actual: ${catlles_ids}
        
    END

Get cattles by modifyDate (ROLE_USER/MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248574
    [Tags]             TC248574
    # Pre-setup
    # Create cattle in common farm
    ${common_farm_id} =      Get Common Farm Id
    ${cattle1_create} =      Create New Cattle            ${common_farm_id}
    ${cattle1_id} =          Set Variable                 ${cattle1_create.json()}[id]
    # Wait some seconds and create cattle2
    Sleep                    5
    ${cattle2_create} =      Create New Cattle            ${common_farm_id}
    ${cattle2_id} =          Set Variable                 ${cattle2_create.json()}[id]
    # Get cattle modifyDate
    ${get_cattle_resp} =     Get Cattle By ID             ${cattle2_id}
    ${cattle_modifyDate} =   Set Variable                 ${get_cattle_resp.json()}[modifyDate]
    ${modifyDate} =          Evaluate                     ${cattle_modifyDate}-1
    
    # Test
    # Use regular/manager user
    ${role} =               Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[${role}][token]
    # Get cattles by modifyDate
    ${cattles_resp} =       Get Cattles                  modifyDate=${modifyDate}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    
    # Get list of cattles id
    ${catlles_ids} =        Evaluate                     [i['id'] for i in ${cattles_info}]
    # Check cattle1 id is not in list
    List Should Not Contain Value      ${catlles_ids}    ${cattle1_id}    Cattle id '${cattle1_id}' should not exist in cattles list. Actual: ${catlles_ids}
    # Check cattle2 id is in list
    List Should Contain Value          ${catlles_ids}    ${cattle2_id}    Cattle id '${cattle2_id}' should exist in cattles list. Actual: ${catlles_ids}

Get cattles by sortOrder (ROLE_USER/MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248578
    [Tags]             TC248578
    # Pre-setup
    # Create cattles
    ${common_farm_id} =      Get Common Farm Id
    FOR  ${i}  IN RANGE    3
        ${earTag} =          Generate Random String       10    [LETTERS][NUMBERS]
        Create New Cattle    ${common_farm_id}            earTag=${earTag}
    END    
    
    # Test
    # Choose order randomly
    ${order} =              Evaluate                     random.choice(['ASC', 'DESC'])
    # Use regular/manager user
    ${role} =               Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[${role}][token]
    # Get cattles
    ${cattles_resp} =       Get Cattles                  sortOrder=${order}
    ${cattles_info} =       Set Variable                 ${cattles_resp.json()}
    # By default sorting happing by earTag column
    ${is_sorted} =          Check If List Of Dicts Is Sorted    list_of_dicts=${cattles_info}    field_name=earTag    order=${order}
    Should Be True          ${is_sorted}    Cattles list should be sorted by modifyDate in '${order}' order. Actual: ${cattles_info}

Get cattles by sortColumn (ROLE_USER/MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248581
    [Tags]             TC248581
    # Pre-setup
    # Create farm
    ${common_enterprise_id} =       Get Common Enterprise Id
    ${create_farm} =                Create New Farm                     ${common_enterprise_id}
    ${farm_id} =                    Set Variable                        ${create_farm.json()}[id]
    # Create user
    ${role} =                       Evaluate                            random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${user_pass}  ${create_user} =  Create User With Password Common    farm_id=${farm_id}    role=${role}
    ${user_name} =                  Set Variable                        ${create_user.json()}[username]

    # Create cattles    
    FOR  ${i}  IN RANGE    3
        ${collar_info} =     Create New Collar   ${farm_id}
        Create New Cattle    ${farm_id}          collarId=${collar_info}[id]
    END    
    
    # Test
    # Choose order randomly
    ${sortColumn} =         Evaluate             random.choice(['id', 'earTag', 'collarId', 'transportId'])
    # Use created user
    Use Specific User For API Calls              user_name=${user_name}    user_password=${user_pass}
    # Get cattles
    ${cattles_resp} =       Get Cattles          sortColumn=${sortColumn}
    ${cattles_info} =       Set Variable         ${cattles_resp.json()}
    # By default sorting happing by ASC order
    ${is_sorted} =          Check If List Of Dicts Is Sorted    list_of_dicts=${cattles_info}    field_name=${sortColumn}    order=ASC
    Should Be True          ${is_sorted}    Cattles list should be sorted by '${sortColumn}' in ASC order. Actual: ${cattles_info}

Get cattles - Schema validation
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/253137
    [Tags]           TC253137
    # Pre-setup
    ${common_farm_id} =    Get Common Farm Id
    ${earTag} =            Generate Random String         128
    &{collar_info} =       Create New Collar              ${common_farm_id}
    ${collar_id} =         Set Variable                   ${collar_info}[id]
    ${electronicId} =      Generate Random String         128
    ${regulatoryId} =      Generate Random String         128
    ${phNumber} =          Generate Random String         128
    ${brand} =             Generate Random String         128
    ${type} =              Generate Random String         32
    ${breed} =             Generate Random String         64
    ${color} =             Generate Random String         128
    ${horn} =              Generate Random String         32
    ${birth} =             Evaluate                       random.randint(0, 9223372036854775)    modules=random
    ${notes} =             Generate Random String         4096

    # Create cow in common farm
    ${create_cattle_response} =    Create New Cattle    farm_id=${common_farm_id}
...                                                     earTag=${earTag}
...                                                     collarId=${collarId}
...                                                     electronicId=${electronicId}
...                                                     regulatoryId=${regulatoryId}
...                                                     phNumber=${phNumber}
...                                                     brand=${brand}
...                                                     type=${type}
...                                                     breed=${breed}
...                                                     color=${color}
...                                                     horn=${horn}
...                                                     birth=${birth}
...                                                     notes=${notes}
    
    ${created_cow_id} =             Set Variable        ${create_cattle_response.json()}[id]

    # Test
    ${get_cattles_response} =         Get Cattles
    ${cow_found} =    Set Variable    ${False}
    FOR  ${cow_object}  IN  @{get_cattles_response.json()}
        ${cow_id} =     Set Variable    ${cow_object}[id]
        IF  '${cow_id}' == '${created_cow_id}'
            ${cow_found} =    Set Variable    ${True}
            Validate Json Schema By File    CattleView.json    ${cow_object}
        END
    END
    Should Be True    ${cow_found}    Cattle id '${cow_id}' should exist in cattles list. Actual: ${get_cattles_response}
