*** Settings ***
Documentation    https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=268363

Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource         ../../../../../../resources/api/Keywords/HerdManagerAPI/herd_history.robot

Suite Setup      Run Only Once       Create API Session With Common Users
Suite Teardown   Clean Up

Test Tags        GET    Positive

*** Test Cases ***
Find herd collar history by ID (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/258525
    [Tags]           TC258525
    # Pre-Setup
    ${enterprise_id} =       Get Common Enterprise Id
    ${farm_id} =             Get Common Farm Id
    # Create collar
    ${collar_info} =         Create New Collar                 farm_id=${farm_id}
    ${collar_id} =           Set Variable                      ${collar_info}[id]
    ${collar_ids} =          Create List                       ${collar_id}
    # Create herd
    ${create_herd} =         Create New Herd                   farm_id=${farm_id}    collarIds=${collar_ids}
    ${herd_id} =             Set Variable                      ${create_herd.json()}[id]
    # Get id of the record in the herd_collar_history DB table
    ${db_records} =          Get Collar History From DB By Herd Id    ${herd_id}
    ${history_id} =          Set Variable                      ${db_records}[0][0]

    # Test
    # Use ROLE_USER
    ${users} =               Get Common Users
    Use Specific User For API Calls                            user_token=${users}[ROLE_USER][token]
    ${response} =            Get Herd Collar History By Id     ${history_id}
    # Check fields
    Should Be Equal          ${response.json()}[enterpriseId]  ${enterprise_id}     'enterpriseId' is not equal to expected. Actual: ${response.json()}[enterpriseId]. Expected: ${enterprise_id}
    Should Be Equal          ${response.json()}[farmId]        ${farm_id}           'farmId' is not equal to expected. Actual: ${response.json()}[farmId]. Expected: ${farm_id}
    Should Be Equal          ${response.json()}[herdId]        ${herd_id}           'herdId' is not equal to expected. Actual: ${response.json()}[herdId]. Expected: ${herd_id}
    Should Be Equal          ${response.json()}[collarIds][0]  ${collar_id}         'collardId' is not equal to expected. Actual: ${response.json()}[collarIds][0]. Expected: ${collar_id}   
