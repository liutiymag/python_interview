*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=250540

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         POST    Negative

*** Test Cases ***
Update not existing cattle (ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250547
    [Tags]           TC250547
    # Pre-setup    
    ${farm_id} =       Get Common Farm Id
    ${create_resp} =   Create New Cattle              ${farm_id}
    ${cattle_info} =   Set Variable                   ${create_resp.json()}
    ${cattle_id} =     Generate UUID

    # Choose user role
    ${user_role} =        Evaluate                       random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${response} =       Do API call    PUT    ${CATTLE_URL}/${cattle_id}    json=${cattle_info}    expected_status=404
    ${response_json} =  Set Variable   ${response.json()}
    Should Be Equal As Strings      ${response_json}[message]      CATTLE_NOT_FOUND_BY_ID  Actual value "${response_json}[message]" is not equal to expected "CATTLE_NOT_FOUND_BY_ID"
    Should Be Equal As Strings      ${response_json}[values][0]    ${cattle_id}            Actual value "${response_json}[values][0]" is not equal to expected "${cattle_id}"

Update cattle belonging to another farm (ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250548
    [Tags]           TC250548
    # Pre-setup
    # Create a new farm
    ${enterprise_id} =  Get Common Enterprise Id
    ${create_farm} =    Create New Farm               ${enterprise_id}
    ${farm_id} =        Set Variable                  ${create_farm.json()}[id]
    # Create a new cattle
    ${create_resp} =    Create New Cattle             ${farm_id}
    ${cattle_info} =    Set Variable                  ${create_resp.json()}
    ${cattle_id} =      Set Variable                  ${cattle_info}[id]

    # Choose user role
    ${user_role} =        Evaluate                       random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${cattle_info}[earTag] =  Generate Random String     128
    ${response} =       Do API call    PUT    ${CATTLE_URL}/${cattle_id}    json=${cattle_info}    expected_status=403
    Should Be Equal As Strings    ${response.json()}[message]  Access is denied  Actual value "${response.json()}[message]" is not equal to expected "Access is denied"

Update cattle with status = null (ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250550
    [Tags]           TC250550
    # Pre-setup
    ${farm_id} =        Get Common Farm Id
    # Create a new cattle
    ${create_resp} =    Create New Cattle             ${farm_id}
    ${cattle_info} =    Set Variable                  ${create_resp.json()}
    ${cattle_info}[status] =    Set Variable          ${null}
    ${cattle_id} =      Set Variable                  ${cattle_info}[id]

    # Choose user role
    ${user_role} =        Evaluate                       random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${response} =       Do API call    PUT    ${CATTLE_URL}/${cattle_id}    json=${cattle_info}    expected_status=400
    Check Failure is Present     ${response.json()}    expected_failure_key=STATUS_IS_EMPTY    expected_fieldName=status

Update cattle with already existing earTag(ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250556
    [Tags]           TC250556
    # Pre-setup
    ${farm_id} =          Get Common Farm Id
    # Create cattles
    ${create_A_resp} =    Create New Cattle           ${farm_id}
    ${cattle_A_info} =    Set Variable                ${create_A_resp.json()}
    ${cattle_A_id} =      Set Variable                ${cattle_A_info}[id]

    ${cattle_B_earTag} =  Generate Random String      128
    Create New Cattle     ${farm_id}                  earTag=${cattle_B_earTag}

    # Choose user role
    ${user_role} =        Evaluate                    random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${cattle_A_info}[earTag] =    Set Variable        ${cattle_B_earTag} 
    ${response} =       Do API call    PUT    ${CATTLE_URL}/${cattle_A_id}    json=${cattle_A_info}    expected_status=400
    Check Failure is Present     ${response.json()}    expected_failure_key=EAR_TAG_ALREADY_EXISTS    expected_fieldName=earTag

Update cattle with already existing collarId(ROLE_MANAGER/USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/250561
    [Tags]           TC250561
    # Pre-setup
    ${farm_id} =            Get Common Farm Id
    # Create cattles
    ${create_A_resp} =      Create New Cattle           ${farm_id}
    ${cattle_A_info} =      Set Variable                ${create_A_resp.json()}
    ${cattle_A_id} =        Set Variable                ${cattle_A_info}[id]

    &{collar_info} =        Create New Collar           ${farm_id}
    ${cattle_B_collarId} =  Set Variable                ${collar_info}[id]
    Create New Cattle       ${farm_id}                  collarId=${cattle_B_collarId}

    # Choose user role
    ${user_role} =        Evaluate                    random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[${user_role}][token]

    # Test
    ${cattle_A_info}[collarId] =    Set Variable        ${cattle_B_collarId} 
    ${response} =       Do API call    PUT    ${CATTLE_URL}/${cattle_A_id}    json=${cattle_A_info}    expected_status=400
    Check Failure is Present     ${response.json()}    expected_failure_key=COLLAR_ID_ALREADY_EXISTS    expected_fieldName=collarId
