*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=250540

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/enterprise.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         PUT    Positive

*** Test Cases ***
Update cattle (ROLE_SECRET_PROJECT)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250541
    [Tags]           TC250541
    # Pre-setup
    # Create enterprise and farm
    ${enterprise_create} =  Create Enterprise
    ${enterprise_id} =      Set Variable                   ${enterprise_create.json()}[id]
    ${farm_create} =        Create New Farm                ${enterprise_id}
    ${farm_id} =            Set Variable                   ${farm_create.json()}[id]

    ${earTag} =             Generate Random String         128
    ${create_response} =    Create New Cattle  ${farm_id}  earTag=${earTag}
    ${cattle_id} =          Set Variable                   ${create_response.json()}[id]

    # Test
    ${new_earTag} =         Generate Random String         128
    &{collar_info} =        Create New Collar              ${farm_id}
    ${collar_id} =          Set Variable                   ${collar_info}[id]
    
    ${response} =           Update Cattle                  ${cattle_id}
    ...                                                    earTag=${new_earTag}
    ...                                                    collarId=${collarId}
    # Check response
    Should Be Equal As Strings  ${cattle_id}   ${response.json()}[id]          'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}
    Should Be Equal As Strings  ${new_earTag}  ${response.json()}[earTag]      'earTag' value is not equal to expected. Actual: ${response.json()}[earTag]. Expected: ${new_earTag}
    Should Be Equal As Strings  ${collarId}    ${response.json()}[collarId]    'collarId' value is not equal to expected. Actual: ${response.json()}[collarId]. Expected: ${collarId}
    
Update cattle status (ROLE_SECRET_PROJECT)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250544
    [Tags]           TC250544
    # Pre-setup
    ${farm_id} =          Get Common Farm Id
    ${create_response} =  Create New Cattle              ${farm_id}
    ${cattle_id} =        Set Variable                   ${create_response.json()}[id]

    # Test
    ${new_status} =       Set Variable                   INACTIVE    
    ${response} =         Update Cattle                  ${cattle_id}
    ...                                                  status=${new_status}
    # Check response
    Should Be Equal As Strings  ${new_status}  ${response.json()}[status]    'status' value is not equal to expected. Actual: ${response.json()}[status]. Expected: ${new_status}
    
Update cattle (ROLE_ADMIN)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250545
    [Tags]           TC250545
    # Pre-setup
    # Create farm
    ${enterprise_id} =    Get Common Enterprise Id
    ${farm_create} =      Create New Farm                ${enterprise_id}
    ${farm_id} =          Set Variable                   ${farm_create.json()}[id]
    ${create_response} =  Create New Cattle              ${farm_id}
    ${cattle_id} =        Set Variable                   ${create_response.json()}[id]
    
    # Use ADMIN user for API calls
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_ADMIN][token]
    
    # Test
    ${new_earTag} =       Generate Random String         128
    ${response} =         Update Cattle                  ${cattle_id}
    ...                                                  earTag=${new_earTag}
    # Check response
    Should Be Equal As Strings  ${cattle_id}  ${response.json()}[id]         'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}
    Should Be Equal As Strings  ${new_earTag}  ${response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${response.json()}[earTag]. Expected: ${new_earTag}
    
Update cattle (ROLE_MANAGER/USER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250546
    [Tags]             TC250546
    # Pre-setup
    # Create farm
    ${farm_id} =          Get Common Farm Id
    ${create_response} =  Create New Cattle              ${farm_id}
    ${cattle_id} =        Set Variable                   ${create_response.json()}[id]
    
    # Use regular/manager user for API calls
    ${user_role} =        Evaluate                       random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]
    
    # Test
    ${new_earTag} =       Generate Random String         128
    ${response} =         Update Cattle                  ${cattle_id}
    ...                                                  earTag=${new_earTag}
    # Check response
    Should Be Equal As Strings  ${cattle_id}  ${response.json()}[id]         'id' value is not equal to expected. Actual: ${response.json()}[id]. Expected: ${cattle_id}
    Should Be Equal As Strings  ${new_earTag}  ${response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${response.json()}[earTag]. Expected: ${new_earTag}

Update inactive cattle (ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250554
    [Tags]           TC250554
    # Pre-setup
    # Create cattle and set status INACTIVE
    ${farm_id} =              Get Common Farm Id
    ${create_response} =      Create New Cattle            ${farm_id}
    ${cattle_id} =            Set Variable                 ${create_response.json()}[id]
    ${inactive_resp} =        Update Cattle                ${cattle_id}                 status=INACTIVE

    # Choose user role
    ${user_role} =            Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =                Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${new_earTag} =           Generate Random String       128
    ${response} =             Update Cattle                ${cattle_id}
    ...                                                    earTag=${new_earTag}
    # Check response
    Should Be Equal As Strings  ${new_earTag}  ${response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${response.json()}[earTag]. Expected: ${new_earTag}

Update cattle - Schema validation
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/253268
    [Tags]           TC253268
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
    ${new_earTag} =       Generate Random String         128
    ${response} =         Update Cattle                  ${created_cow_id}
    ...                                                  earTag=${new_earTag}
    Validate Json Schema By File         CattleView.json                ${response.json()}
