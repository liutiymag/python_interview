*** Settings ***
Resource      ./user.robot
Resource      ./collar.robot
Resource      ../../Variables/herd.robot

*** Variables ***
${HERD_URL} =       ${BASE_URL_API}/herd

*** Keywords ***
Create New Herd
    [Arguments]    ${farm_id}=${None}    ${paddock_ids}=[]    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    # Set user farm id
    IF    ${{$farm_id is not None}}
            ${params} =        Create Dictionary    farmId=${farm_id}
            ${current_farm} =  Set Variable         ${farm_id}
    ELSE
        ${user_farm} =         Get User Farm
        ${current_farm} =      Set Variable         ${user_farm.json()}[id]
    END
    # Set collars ids
    IF  ${{'collarIds' in &{kwargs}}}
        ${collarIds} =         Set Variable         ${kwargs}[collarIds]
    ELSE
        # Create collar
        &{collar_info} =       Create New Collar    ${current_farm}
        ${collar_id} =         Set Variable         ${collar_info}[id]
        ${collarIds} =         Create List          ${collar_id}
    END
    
    # Create herd request body
    ${name} =              Generate Random String   128
    ${color} =             Evaluate                 random.choice(${HERD_COLORS})
    ${nextActions} =       Create List
    ${datetime} =          Evaluate                 int(time.time())-10000
    ${slots} =             Create Herd Slots        paddock_ids=${paddock_ids}    date=${datetime}
    ${herd_info} =         Create Dictionary        name=${name}
    ...                                             nextActions=${nextActions}
    ...                                             collarIds=${collarIds}
    ...                                             slots=${slots}
    ...                                             movementAlert=${False}
    ...                                             color=${color}

    FOR    ${key}    IN    @{kwargs}
        ${herd_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =      Do API call    POST    ${HERD_URL}    params=${params}    json=${herd_info}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created herd with ID: ${response.json()}[id]
    END
    RETURN    ${response}

Get Herds
    [Arguments]    ${expected_status}=200    &{params}
    ${response} =  Do API call    GET    ${HERD_URL}    params=${params}    expected_status=${expected_status}
    RETURN    ${response}

Get Herd By Id
    [Arguments]    ${herd_id}    ${expected_status}=200
    ${response} =  Do API call   GET    ${HERD_URL}/${herd_id}    expected_status=${expected_status}
     RETURN        ${response}

Get Herd Collars
    [Arguments]    ${herd_id}    ${expected_status}=200
    ${response} =  Do API call    GET    ${HERD_URL}/${herd_id}/collar    expected_status=${expected_status}
    RETURN    ${response}

Update Herd By Id
    [Arguments]    ${herd_id}    ${expected_status}=200    &{kwargs}
    # Get herd info
    ${info_resp} =   Get Herd By Id       ${herd_id}
    ${herd_info} =   Create Dictionary    name=${info_resp.json()}[name]
    ...                                   nextActions=${info_resp.json()}[nextActions]
    ...                                   slots=${info_resp.json()}[slots]
    ...                                   movementAlert=${info_resp.json()}[movementAlert]
    ...                                   color=${info_resp.json()}[color]
    ...                                   status=${info_resp.json()}[status]
    ...                                   version=${info_resp.json()}[version]

    # Update herd info
    FOR    ${key}    IN    @{kwargs}
        ${herd_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END

    ${response} =      Do API call    PUT    ${HERD_URL}/${herd_id}    json=${herd_info}    expected_status=${expected_status}
    RETURN    ${response}

Split Herd By Id
    [Arguments]    ${herd_id}    ${expected_status}=200    &{body}
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/split    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Add To Herd
    [Arguments]    ${herd_id}    ${collarIds}    ${expected_status}=200
    ${body} =      Create Dictionary    collarIds=${collarIds}
    ${response} =  Do API call   POST   ${HERD_URL}/${herd_id}/add    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Unherd Herd By Id
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/unherd    expected_status=${expected_status}

Move Collars From Herd
    [Arguments]    ${from_herd_id}    ${to_herd_id}    ${collarIds_list}    ${expected_status}=200
    ${body} =      Create Dictionary     herdId=${to_herd_id}    collarIds=${collarIds_list}
    ${response} =  Do API call   POST    ${HERD_URL}/${from_herd_id}/move    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Remove Collars From Herd
    [Arguments]    ${herd_id}    ${collarIds}    ${expected_status}=200
    ${body} =      Create Dictionary    collarIds=${collarIds}
    ${response} =  Do API call   POST   ${HERD_URL}/${herd_id}/remove    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Resync Herd By Id
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/resync    expected_status=${expected_status}
    RETURN    ${response}

Retry Herd Sync
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/retry    expected_status=${expected_status}
    RETURN    ${response}

Clear Herd Paddocks
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/reset    expected_status=${expected_status}
    RETURN    ${response}

Deactivate Herd Paddocks
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/deactivate    expected_status=${expected_status}
    RETURN    ${response}

Clear Collars Queue By Herd Id
    [Arguments]    ${herd_id}    ${expected_status}=204
    ${response} =  Do API call   DELETE    ${HERD_URL}/${herd_id}/queue    expected_status=${expected_status}
    RETURN    ${response}

Get Herd Audit By Id
    [Arguments]    ${herd_id}    ${expected_status}=200
    ${response} =  Do API call   GET    ${HERD_URL}/${herd_id}/audit    expected_status=${expected_status}
    RETURN    ${response}

Get Herd Progress
    [Arguments]    ${herd_ids_list}    ${expected_status}=200
    ${body} =      Create Dictionary   herdIds=${herd_ids_list}
    ${response} =  Do API call  POST   ${HERD_URL}/progress    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Update Herd Shock By Id
    [Arguments]    ${herd_id}    ${expected_status}=204    &{body}
    ${response} =  Do API call   POST    ${HERD_URL}/${herd_id}/shock    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Wait Herd Progress Completed
    [Arguments]    ${herd_id}    ${timeout}=40
    ${request_interval} =    Set Variable    ${2}
    ${time_elapsed} =        Set Variable    ${0}
    ${herd_ids_list} =       Create List     ${herd_id}
    
    WHILE  ${time_elapsed}<=${timeout}
        ${response} =  Get Herd Progress    ${herd_ids_list}
        IF  '${response.json()}[progress][0][progress]'=='1.0'
            RETURN
        ELSE
            Sleep     ${request_interval}
            ${time_elapsed} =    Evaluate    ${time_elapsed}+${request_interval}
        END
    END

    Fail    Herd progress is not completed in time
