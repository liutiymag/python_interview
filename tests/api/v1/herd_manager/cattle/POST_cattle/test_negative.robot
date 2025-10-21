*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248340

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/user.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         POST    Negative

*** Test Cases ***
Create cattle with farmId not exist (ROLE_SECRET_PROJECT)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248432
    [Tags]           TC248432
    # Pre-setup
    ${farm_id} =     Evaluate    uuid.uuid4()    uuid

    # Test
    ${create_response} =         Create New Cattle  ${farm_id}    expected_status=400
    Check Failure is Present     ${create_response.json()}    expected_failure_key=FARM_NOT_EXISTS    expected_fieldName=farmId

Create cattle with earTag already in use (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248434
    [Tags]           TC248434
    # Pre-setup
    ${earTag} =           Generate Random String        128
    
    # Use regular user for API calls
    ${users} =            Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_USER][token]

    # Create cattle
    ${create_response} =   Create New Cattle    earTag=${earTag}
    # Create cattle second time
    ${failed_response} =   Create New Cattle    earTag=${earTag}    expected_status=400
    Check Failure is Present     ${failed_response.json()}    expected_failure_key=EAR_TAG_ALREADY_EXISTS    expected_fieldName=earTag

Create cattle with collarId already in use (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248435
    [Tags]           TC248435
    # Pre-setup
    ${farm_id} =       Get Common Farm Id
    &{collar_info} =   Create New Collar              ${farm_id}
    ${collar_id} =     Set Variable                   ${collar_info}[id]

    # Use regular user for API calls
    ${users} =         Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_USER][token]

    # Create cattle
    ${create_response} =    Create New Cattle    collarId=${collar_id}
    # Create cattle second time
    ${failed_response} =    Create New Cattle    collarId=${collar_id}    expected_status=400
    Check Failure is Present     ${failed_response.json()}    expected_failure_key=COLLAR_ID_ALREADY_EXISTS    expected_fieldName=collarId

Create cattle with user changed viewFarmId (ROLE_ADMIN)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/253227
    [Tags]           TC253227
    # Pre-setup
    # Create admin user in common farm
    ${common_farm_id} =   Get Common Farm Id
    ${password}    ${user_create_resp} =    Create User With Password    farm_id=${common_farm_id}    role=ROLE_ADMIN
    ${username} =         Set Variable                  ${user_create_resp.json()}[username]
    # Create new farm in common enterprise
    ${enterprise_id} =    Get Common Enterprise Id
    ${farm_resp} =        Create New Farm               enterprise_id=${enterprise_id}
    ${farm_id} =          Set Variable                  ${farm_resp.json()}[id]

    ${earTag} =           Generate Random String        128
    
    # Use admin user for API calls
    Use Specific User For API Calls    user_name=${username}    user_password=${password}

    # Update user viewFarmId
    Update User View Farm ID    ${farm_id}

    # Create cattle
    ${create_response} =    Create New Cattle    earTag=${earTag}
    Should Be Equal As Strings   ${earTag}       ${create_response.json()}[earTag]    'earTag' value is not equal to expected. Actual: ${create_response.json()}[earTag]. Expected: ${earTag}

    # Check cattle is not present in original common farm
    ${cattles_resp} =       Get Cattles          farmId=${common_farm_id}
    ${catlles_ids} =        Evaluate             [i['id'] for i in ${cattles_resp.json()}]

    List Should Not Contain Value    ${catlles_ids}    ${create_response.json()}[id]    Cattle id '${create_response.json()}[id]' should not exist in cattles list. Actual: ${catlles_ids}

Create cattle with farmId not exist (ROLE_ADMIN)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/265840
    [Tags]           TC265840
    # Pre-setup
    ${farm_id} =    Evaluate    uuid.uuid4()    modules=uuid

    # Use regular user for API calls
    ${users} =              Get Common Users
    Use Specific User For API Calls    user_token=${users}[ROLE_ADMIN][token]

    # Create cattle
    ${create_response} =    Create New Cattle    farm_id=${farm_id}    expected_status=400
    Check Failure is Present     ${create_response.json()}    expected_failure_key=FARM_NOT_EXISTS    expected_fieldName=farmId
