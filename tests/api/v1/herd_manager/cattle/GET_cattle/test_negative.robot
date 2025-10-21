*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=248397

Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/cattle.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/collar.robot

Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         GET    Negative

*** Test Cases ***
Get the cattle by invalid modifyDate (ROLE_USER/MANAGER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/248584
    [Tags]           TC248584
    # Pre-setup
    # Create cattles  
    ${common_farm_id} =     Get Common Farm Id
    FOR  ${i}  IN RANGE     3
        ${create_resp} =    Create New Cattle            ${common_farm_id}
    END    
    
    # Test
    # Create modifyDate
    ${modifyDate} =         Evaluate                     ${create_resp.json()}[modifyDate]+10000
    # Use regular/manager user
    ${role} =               Evaluate                     random.choice(['ROLE_USER', 'ROLE_MANAGER'])
    ${users} =              Get Common Users
    Use Specific User For API Calls                      user_token=${users}[${role}][token]
    # Get cattles by status
    ${cattles_resp} =       Get Cattles                  modifyDate=${modifyDate}
    Length Should Be        ${cattles_resp.json()}   0   Should be 0 cattles in list. Actual number: ${{len(${cattles_resp.json()})}}
