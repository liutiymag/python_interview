*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248340

Resource      ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource      ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags    POST    Positive

*** Test Cases ***
Create cattle with farmId (ROLE_SECRET_PROJECT)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248402
    [Tags]           TC248402
    # Pre-setup
    ${farm_id} =     Get Common Farm Id
    ${earTag} =      Generate Random String         128

    # Test
    ${create_response} =         Create New Cattle      ${farm_id}    earTag=${earTag}
    ${created_count} =           Evaluate               1 if 'id' in ${create_response.json()} else 0    #Count "id" in the response, that there is only 1 cow.
    ${created_cow_id} =          Set Variable           ${create_response.json()}[id]
    Should Be Equal As Strings   ${earTag}              ${create_response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${create_response.json()}[earTag]. Expected: ${earTag}

    # Check the cow created in the right default Farm
    ${get_cattles_response} =    Get Cattles            farmId=${farm_id}
    ${get_cattle_count} =        Get Length             ${get_cattles_response.json()}

    Should Be True    ${get_cattle_count}>=${created_count}    Not enough collars in response. Actual count: ${get_cattle_count}. Expected: >=${created_count}
    ${get_response_ids} =        Evaluate                      [k['id'] for k in ${get_cattles_response.json()}]
    List Should Contain Value    ${get_response_ids}   ${created_cow_id}    Not all created collars are present in response. Created: ${created_cow_id}. Response: @{get_response_ids}

Create cattle with farmId (ROLE_ADMIN)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248403
    [Tags]           TC248403
    # Pre-setup
    # Create new farm in common enterprise
    ${enterprise_id} =    Get Common Enterprise Id
    ${farm_resp} =        Create New Farm               enterprise_id=${enterprise_id}
    ${farm_id} =          Set Variable                  ${farm_resp.json()}[id]

    ${earTag} =           Generate Random String        128
    
    # Use ADMIN user for API calls
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_ADMIN][token]
    
    # Test
    # Create cattle
    ${create_response} =  Create New Cattle    ${farm_id}    earTag=${earTag}
    Should Be Equal As Strings   ${earTag}     ${create_response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${create_response.json()}[earTag]. Expected: ${earTag}
    ${cattle_id} =        Set Variable         ${create_response.json()}[id]
   
    #Check if cattle created in the right  farm 
    # Get cattles from farm
    ${cattles_resp} =       Get Cattles                  farm_id=${farm_id}
    
    # Check cattleId exists for farm
    ${catlles_ids} =        Evaluate            [i['id'] for i in ${cattles_resp.json()}]
    List Should Contain Value          ${catlles_ids}    ${cattle_id}    Cattle id '${cattle_id}' should exist in cattles list. Actual: ${catlles_ids}

Create cattle without farmId (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248404
    [Tags]           TC248404
    # Pre-setup
    ${earTag} =              Generate Random String        128
    ${common_farm_id} =      Get Common Farm Id
    
    # Use regular user for API calls
    ${users} =               Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_USER][token]
    
    # Test
    # Create cattle
    ${create_response} =     Create New Cattle             earTag=${earTag}
    Should Be Equal As Strings   ${earTag}       ${create_response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${create_response.json()}[earTag]. Expected: ${earTag}
    ${created_cattle_id} =    Set Variable    ${create_response.json()}[id]

    # Check the cow created in the right default farm
    ${get_cattles_response} =        Get Cattles                  farmId=${common_farm_id}    # Recive all cows from farm
    ${get_cattles_response_ids} =    Evaluate    [cow_object['id'] for cow_object in ${get_cattles_response.json()}]
    List Should Contain Value    ${get_cattles_response_ids}    ${created_cattle_id}    The created cattle ID is not found in the response. Created ID: ${created_cattle_id}. Response IDs list: ${get_cattles_response_ids}

Create cattle with all fields body (ROLE_MANAGER)
    [Documentation]    https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248431
    [Tags]             TC248431    Smoke
    # Pre-setup
    # Generate data
    ${farm_id} =       Get Common Farm Id
    
    ${earTag} =        Generate Random String         128
    &{collar_info} =   Create New Collar              ${farm_id}
    ${collar_id} =     Set Variable                   ${collar_info}[id]
    ${electronicId} =  Generate Random String         128
    ${regulatoryId} =  Generate Random String         128
    ${phNumber} =      Generate Random String         128
    ${brand} =         Generate Random String         128
    ${type} =          Generate Random String         32
    ${breed} =         Generate Random String         64
    ${color} =         Generate Random String         128
    ${horn} =          Generate Random String         32
    ${birth} =         Evaluate                       random.randint(0, 9223372036854775)    modules=random
    ${notes} =         Generate Random String         4096
    
    # Use manager user for API calls
    ${users} =         Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_MANAGER][token]

    # Create cattle
    ${create_response} =    Create New Cattle     farm_id=${farm_id}
    ...                                           earTag=${earTag}
    ...                                           collarId=${collarId}
    ...                                           electronicId=${electronicId}
    ...                                           regulatoryId=${regulatoryId}
    ...                                           phNumber=${phNumber}
    ...                                           brand=${brand}
    ...                                           type=${type}
    ...                                           breed=${breed}
    ...                                           color=${color}
    ...                                           horn=${horn}
    ...                                           birth=${birth}
    ...                                           notes=${notes}

    Should Be Equal As Strings   ${earTag}        ${create_response.json()}[earTag]        'earTag' value is not equal to expected. Actual: ${create_response.json()}[earTag]. Expected: ${earTag}
    Should Be Equal As Strings   ${collarId}      ${create_response.json()}[collarId]      'collarId' value is not equal to expected. Actual: ${create_response.json()}[collarId]. Expected: ${collarId}
    Should Be Equal As Strings   ${electronicId}  ${create_response.json()}[electronicId]  'electronicId' value is not equal to expected. Actual: ${create_response.json()}[electronicId]. Expected: ${electronicId}
    Should Be Equal As Strings   ${regulatoryId}  ${create_response.json()}[regulatoryId]  'regulatoryId' value is not equal to expected. Actual: ${create_response.json()}[regulatoryId]. Expected: ${regulatoryId}
    Should Be Equal As Strings   ${phNumber}      ${create_response.json()}[phNumber]      'phNumber' value is not equal to expected. Actual: ${create_response.json()}[phNumber]. Expected: ${phNumber}
    Should Be Equal As Strings   ${brand}         ${create_response.json()}[brand]         'brand' value is not equal to expected. Actual: ${create_response.json()}[brand]. Expected: ${brand}
    Should Be Equal As Strings   ${type}          ${create_response.json()}[type]          'type' value is not equal to expected. Actual: ${create_response.json()}[type]. Expected: ${type}
    Should Be Equal As Strings   ${breed}         ${create_response.json()}[breed]         'breed' value is not equal to expected. Actual: ${create_response.json()}[breed]. Expected: ${breed}
    Should Be Equal As Strings   ${color}         ${create_response.json()}[color]         'color' value is not equal to expected. Actual: ${create_response.json()}[color]. Expected: ${color}
    Should Be Equal As Strings   ${horn}          ${create_response.json()}[horn]          'horn' value is not equal to expected. Actual: ${create_response.json()}[horn]. Expected: ${horn}
    Should Be Equal As Strings   ${birth}         ${create_response.json()}[birth]         'birth' value is not equal to expected. Actual: ${create_response.json()}[birth]. Expected: ${birth}
    Should Be Equal As Strings   ${notes}         ${create_response.json()}[notes]         'notes' value is not equal to expected. Actual: ${create_response.json()}[notes]. Expected: ${notes}
    
Create cattle - schema validation
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/253265
    [Tags]           TC253265   

    # Pre-setup
    ${farm_id} =       Get Common Farm Id
    ${earTag} =        Generate Random String         128
    &{collar_info} =   Create New Collar              ${farm_id}
    ${collar_id} =     Set Variable                   ${collar_info}[id]
    ${electronicId} =  Generate Random String         128
    ${regulatoryId} =  Generate Random String         128
    ${phNumber} =      Generate Random String         128
    ${brand} =         Generate Random String         128
    ${type} =          Generate Random String         32
    ${breed} =         Generate Random String         64
    ${color} =         Generate Random String         128
    ${horn} =          Generate Random String         32
    ${birth} =         Evaluate                       random.randint(0, 9223372036854775)    modules=random
    ${notes} =         Generate Random String         4096
    
    # Create cattle
    ${create_response} =    Create New Cattle     farm_id=${farm_id}
    ...                                           earTag=${earTag}
    ...                                           collarId=${collarId}
    ...                                           electronicId=${electronicId}
    ...                                           regulatoryId=${regulatoryId}
    ...                                           phNumber=${phNumber}
    ...                                           brand=${brand}
    ...                                           type=${type}
    ...                                           breed=${breed}
    ...                                           color=${color}
    ...                                           horn=${horn}
    ...                                           birth=${birth}
    ...                                           notes=${notes}

    Validate Json Schema By File         CattleView.json               ${create_response.json()}
