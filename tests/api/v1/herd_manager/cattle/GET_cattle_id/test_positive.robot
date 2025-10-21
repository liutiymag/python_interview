*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248591

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/enterprise.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         GET    Positive

*** Test Cases ***
Get cattle by Id (ROLE_SECRET_PROJECT) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248592
    [Tags]           TC248592
    # Pre-setup
    # Create enterprise and farm
    ${enterprise_create} =  Create Enterprise
    ${enterprise_id} =      Set Variable                 ${enterprise_create.json()}[id]
    ${farm_create} =        Create New Farm              enterprise_id=${enterprise_id}
    ${farm_id} =            Set Variable                 ${farm_create.json()}[id]
    # Create two cattles
    ${cattle_a} =          Create New Cattle             ${farm_id}
    ${cattle_a_id} =       Set Variable                  ${cattle_a.json()}[id]
    ${cattle_b} =          Create New Cattle             ${farm_id}
    ${cattle_b_id} =       Set Variable                  ${cattle_b.json()}[id]

    # Get random cattle id
    ${cattle_id} =         Evaluate    random.choice(['${cattle_a_id}', '${cattle_b_id}'])

    # Test
    ${response} =         Get Cattle By ID    ${cattle_id}
    Should Be Equal As Strings   ${cattle_id}          ${response.json()}[id]    'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}

Get cattle by Id in the enterprise (ROLE_ADMIN)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248598
    [Tags]           TC248598
    # Pre-setup    
    ${enterprise_id} =      Get Common Enterprise Id
    # Create Farm A
    ${farm_A_resp} =        Create New Farm               enterprise_id=${enterprise_id}
    ${farm_A_id} =          Set Variable                  ${farm_A_resp.json()}[id]
    # Create cattle A
    ${cattle_A_response} =  Create New Cattle             ${farm_A_id}
    ${cattle_A_id} =        Set Variable                  ${cattle_A_response.json()}[id]
    # Create Farm B
    ${farm_B_resp} =        Create New Farm               enterprise_id=${enterprise_id}
    ${farm_B_id} =          Set Variable                  ${farm_B_resp.json()}[id]
    # Create cattle B
    ${cattle_B_response} =  Create New Cattle             ${farm_B_id}
    ${cattle_B_id} =        Set Variable                  ${cattle_B_response.json()}[id]
    
    # Use ADMIN user for API calls
    ${users} =              Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_ADMIN][token]

    # Get random cattle
    ${cattle_id} =        Evaluate               random.choice(['${cattle_A_id}', '${cattle_B_id}'])
    ${response} =         Get Cattle By ID       ${cattle_id}
    Should Be Equal As Strings   ${cattle_id}    ${response.json()}[id]    'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}

Get cattle by Id in the farm (ROLE_USER/MANAGER) 
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248613
    [Tags]           TC248613
    # Pre-setup
    # Create cattle in common farm
    ${farm_id} =          Get Common Farm Id
    ${create_response} =  Create New Cattle             ${farm_id}
    ${cattle_id} =        Set Variable                  ${create_response.json()}[id]
    
    # Use USER/MANAGER user for API calls
    ${users} =            Get Common Users
    ${role} =             Evaluate                      random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    Use Specific User For API Calls                     user_token=${users}[${role}][token]

    # Test
    ${response} =         Get Cattle By ID             ${cattle_id}
    Should Be Equal As Strings   ${cattle_id}          ${response.json()}[id]    'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}
    
Get INACTIVE cattle by Id (ROLE_USER/MANAGER) 
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248615
    [Tags]             TC248615
    # Pre-setup
    # Create cattle and set status INACTIVE
    ${farm_id} =          Get Common Farm Id
    ${create_response} =  Create New Cattle            ${farm_id}
    ${cattle_id} =        Set Variable                 ${create_response.json()}[id]
    Update Cattle         ${cattle_id}                 status=INACTIVE
    
    # Use USER/MANAGER user for API calls
    ${users} =            Get Common Users
    ${role} =             Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    Use Specific User For API Calls                    user_token=${users}[${role}][token]

    # Test
    ${response} =         Get Cattle By ID             ${cattle_id}
    Should Be Equal As Strings   ${cattle_id}          ${response.json()}[id]        'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}
    Should Be Equal As Strings   INACTIVE              ${response.json()}[status]    'status' value is not equal to expected. Actual: ${response.json()}[status]. Expected: INACTIVE

Get cattle by id - Schema validation
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/253267
    [Tags]           TC253267
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
    ${response} =         Get Cattle By ID              ${created_cow_id}
    Validate Json Schema By File         CattleView.json               ${response.json()}
