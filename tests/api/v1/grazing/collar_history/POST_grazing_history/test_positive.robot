*** Settings ***
Documentation     https://dev.azure.com/AHITL/SECRET_PROJECT/_testPlans/define?planId=230842&suiteId=273253

Resource          ../../../../../../resources/api/Keywords/GrazingAPI/collar_history.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/herd.robot
Resource          ../../../../../../resources/api/Keywords/HerdManagerAPI/landmark.robot


Suite Setup       Run Only Once       Create API Session With Common Users
Suite Teardown    Clean Up

Test Tags         POST    Positive

*** Test Cases ***
Get grazing history (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/273302
    [Tags]           TC273302
    # Pre-setup
    # Create collar in common farm
    ${common_farm_id} =    Get Common Farm Id
    ${create_collar} =     Create New Collar            ${common_farm_id}
    ${collar_id} =         Set Variable                 ${create_collar}[id]
    ${transport_id} =      Set Variable                 ${create_collar}[transportId]
    ${collar_list} =       Create List                  ${collar_id}
    
    # Create herd
    ${create_herd} =       Create New Herd              farm_id=${common_farm_id}    collarIds=${collar_list}
    ${herd_id} =           Set Variable                 ${create_herd.json()}[id]

    # Create polygon landmark
    ${location} =          Create Dictionary            type=Polygon
    ${landmark_resp} =     Create New Landmark          farm_id=${common_farm_id}    location=${location}
    ${landmark_id} =       Set Variable                 ${landmark_resp.json()}[id]

    # Generate grazing data
    ${start_date}    ${end_date} =    Generate Random Dates Within 24 Hours    # Default period is between 2020-01-01 00:00:00 and 2041-12-31 23:59:59
    Generate Grazing By Landmark    herdId=${herd_id}   landmarkId=${landmark_id}    start_date=${start_date}    end_date=${end_date}

    # Test
    ${herd_record} =      Create Dictionary            herdId=${herd_id}   deviceIds=${collar_list}
    ${herds} =            Create List                  ${herd_record}
    
    ${users} =            Get Common Users
    Use Specific User For API Calls                    user_token=${users}[ROLE_USER][token]
    ${response} =         Get Grazing History          herds=${herds}
    ...                                                from=${start_date}
    ...                                                to=${end_date}

    # Check collarId and transportId are present
    ${found} =  Set Variable    ${False}
    FOR  ${herd}  IN  @{response.json()}[herds]
        IF  '${herd}[id]' == '${herd_id}'
            FOR  ${collar}  IN  @{herd}[collars]
                IF  '${collar}[id]' == '${collar_id}' and '${collar}[transportId]' == '${transport_id}'
                    Should Not Be Empty     ${collar}[points]          Points list is empty.
                    Should Not Be Empty     ${collar}[points][0]       Coordinates point's list is empty.
                    ${found} =  Set Variable    ${True}
                    BREAK   
                END
            END
            BREAK           
        END
    END
    Should Be True    ${found}    Collar not found. ID: ${collar_id}. Transport ID: ${transport_id}

Get grazing history by messages (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/303338
    [Tags]           TC303338
    # Pre-setup
    # Create collar in common farm
    ${common_farm_id} =    Get Common Farm Id
    ${version_code} =      Evaluate                     random.choice(['7', '9'])
    ${create_collar} =     Create New Collar            ${common_farm_id}   version_code=${version_code}
    ${collar_id} =         Set Variable                 ${create_collar}[id]
    ${transport_id} =      Set Variable                 ${create_collar}[transportId]
    ${collar_list} =       Create List                  ${collar_id}
    
    # Create herd
    ${create_herd} =       Create New Herd              farm_id=${common_farm_id}    collarIds=${collar_list}
    ${herd_id} =           Set Variable                 ${create_herd.json()}[id]

    # Create polygon landmark
    ${location} =          Create Dictionary            type=Polygon
    ${landmark_resp} =     Create New Landmark          farm_id=${common_farm_id}    location=${location}
    ${landmark_id} =       Set Variable                 ${landmark_resp.json()}[id]

    # Generate grazing data
    ${start_date}    ${end_date} =    Generate Random Dates Within 24 Hours    # Default period is between 2020-01-01 00:00:00 and 2041-12-31 23:59:59
    Generate Grazing By Landmark    herdId=${herd_id}   landmarkId=${landmark_id}    start_date=${start_date}    end_date=${end_date}

    # Test with GpsFixIndication
    ${herd_record} =      Create Dictionary            herdId=${herd_id}   deviceIds=${collar_list}
    ${herds} =            Create List                  ${herd_record}
    ${messages} =         Create List                  GpsFixIndication
    
    ${users} =            Get Common Users
    Use Specific User For API Calls                    user_token=${users}[ROLE_USER][token]
    ${response} =         Get Grazing History          herds=${herds}
    ...                                                messages=${messages}
    ...                                                from=${start_date}
    ...                                                to=${end_date}

    # Check herdId and transportId are present
    ${found} =  Set Variable    ${False}
    FOR  ${herd}  IN  @{response.json()}[herds]
        IF  '${herd}[id]' == '${herd_id}'
            FOR  ${collar}  IN  @{herd}[collars]
                IF  '${collar}[id]' == '${collar_id}' and '${collar}[transportId]' == '${transport_id}'
                    Should Not Be Empty     ${collar}[points]          Points list is empty.
                    Should Not Be Empty     ${collar}[points][0]       Coordinates point's list is empty.
                    ${found} =  Set Variable    ${True}
                    BREAK   
                END
            END
            BREAK           
        END
    END
    Should Be True    ${found}    Collar not found. ID: ${collar_id}. Transport ID: ${transport_id}

    # Test with GpsLocationExtIndication
    ${messages} =         Create List                  GpsLocationExtIndication
    ${response} =         Get Grazing History          herds=${herds}
    ...                                                messages=${messages}
    ...                                                from=${start_date}
    ...                                                to=${end_date}

    # Check herdId and transportId are present
    ${found} =  Set Variable    ${False}
    FOR  ${herd}  IN  @{response.json()}[herds]
        IF  '${herd}[id]' == '${herd_id}'
            FOR  ${collar}  IN  @{herd}[collars]
                IF  '${collar}[id]' == '${collar_id}' and '${collar}[transportId]' == '${transport_id}'
                    Should Be Empty     ${collar}[points]    Points list should be empty. Actual: ${collar}[points]
                    ${found} =  Set Variable    ${True}
                    BREAK   
                END
            END
            BREAK           
        END
    END
    Should Be True    ${found}    Collar not found. ID: ${collar_id}. Transport ID: ${transport_id}

Get grazing history by specific devices (ROLE_USER)
    [Documentation]  https://dev.azure.com/AHITL/SECRET_PROJECT/_workitems/edit/304504
    [Tags]           TC304504
    # Pre-setup
    # Create collars in common farm
    ${common_farm_id} =    Get Common Farm Id
    ${create_collar_a} =   Create New Collar            ${common_farm_id}
    ${collar_id_a} =       Set Variable                 ${create_collar_a}[id]
    ${transport_id_a} =    Set Variable                 ${create_collar_a}[transportId]

    ${create_collar_b} =   Create New Collar            ${common_farm_id}
    ${collar_id_b} =       Set Variable                 ${create_collar_b}[id]

    ${collar_list} =       Create List                  ${collar_id_a}    ${collar_id_b}
    
    # Create herd
    ${create_herd} =       Create New Herd              farm_id=${common_farm_id}    collarIds=${collar_list}
    ${herd_id} =           Set Variable                 ${create_herd.json()}[id]

    # Create polygon landmark
    ${location} =          Create Dictionary            type=Polygon
    ${landmark_resp} =     Create New Landmark          farm_id=${common_farm_id}    location=${location}
    ${landmark_id} =       Set Variable                 ${landmark_resp.json()}[id]

    # Generate grazing data
    ${start_date}    ${end_date} =    Generate Random Dates Within 24 Hours    # Default period is between 2020-01-01 00:00:00 and 2041-12-31 23:59:59
    Generate Grazing By Landmark    herdId=${herd_id}   landmarkId=${landmark_id}    start_date=${start_date}    end_date=${end_date}

    # Test
    ${deviceIds} =        Create List                  ${collar_id_a}
    ${herd_record} =      Create Dictionary            herdId=${herd_id}   deviceIds=${deviceIds}
    ${herds} =            Create List                  ${herd_record}
    
    ${users} =            Get Common Users
    Use Specific User For API Calls                    user_token=${users}[ROLE_USER][token]
    ${response} =         Get Grazing History          herds=${herds}
    ...                                                from=${start_date}
    ...                                                to=${end_date}

    # Check collarId and transportId are present
    ${found} =  Set Variable    ${False}
    FOR  ${herd}  IN  @{response.json()}[herds]
        IF  '${herd}[id]' == '${herd_id}'
            FOR  ${collar}  IN  @{herd}[collars]
                IF  '${collar}[id]' == '${collar_id_b}'
                    Fail    Collar should not be present in response. ID: ${collar}[id]
                END
                IF  '${collar}[id]' == '${collar_id_a}' and '${collar}[transportId]' == '${transport_id_a}'
                    Should Not Be Empty     ${collar}[points]          Points list is empty.
                    Should Not Be Empty     ${collar}[points][0]       Coordinates point's list is empty.
                    ${found} =  Set Variable    ${True}
                    BREAK   
                END
            END
            BREAK           
        END
    END
    Should Be True    ${found}    Collar not found. ID: ${collar_id_a}. Transport ID: ${transport_id_a}
