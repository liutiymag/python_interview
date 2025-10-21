*** Settings ***
Resource      ../CommonAPI.robot
Resource      ./farm.robot
Resource      ../MessageHandlerAPI/raw_message.robot
Resource      ../../Variables/collar.robot

*** Variables ***
${COLLAR_URL} =       ${BASE_URL_API}/collar

*** Keywords ***
Create New Collar
    [Arguments]    ${farm_id}    ${method}=${None}  ${version_code}=${None}
    IF  ${{$version_code is None }}
        ${version_code} =  Evaluate    random.choice(list($COLLAR_VERSIONS.keys()))
    END
    IF  ${{$method is None }}
        ${method} =  Evaluate    random.choice(['simulator', 'metadata'])
    END
    IF  '${method}'=='simulator'
        Log To Console                     Creating collar in simulator
        ${collar_info} =                   Create New Collar Via Simulator    ${farm_id}    collarType=${COLLAR_VERSIONS}[${version_code}][simulator]
        ${collar_info}[id] =               Set Variable                       ${collar_info}[dbId]
        ${collar_info}[managementState] =  Set Variable                       ${collar_info}[management]
        RETURN    ${collar_info}
    ELSE
        Log To Console        Creating collar with metadata
        ${create_response} =  Create New Collar With Metadata    ${farm_id}   applicationTypeId=${version_code}
        RETURN    ${create_response.json()}
    END    

Create New Collar Via Simulator
    [Arguments]    ${farm_id}    &{kwargs}
    ${application_id} =  Get Farm Transport ID By Farm ID    ${farm_id}    # application_id is a farm transportId

    ${version_code} =           Evaluate           random.choice(list($COLLAR_VERSIONS.keys()))
    ${collarType} =             Set Variable       ${COLLAR_VERSIONS}[${version_code}][simulator]
    ${devEui} =                 Evaluate           secrets.token_hex(16)    # Generate 32 digits hex number
    ${latitude} =               Evaluate           random.uniform(-90, 90)
    ${longitude} =              Evaluate           random.uniform(-180, 180)
    
    ${collar_info_create} =     Create Dictionary  collarType=${collarType}
    ...                                            devEui=${devEui}
    ...                                            applicationId=${application_id}
    ...                                            latitude=${latitude}
    ...                                            longitude=${longitude}
    ...                                            count=${1}

    FOR    ${key}    IN    @{kwargs}
        ${collar_info_create}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    
    ${create_response} =    Create New Collar In Simulator    ${collar_info_create}
    Length Should Be        ${create_response.json()}    1
    ${collar_info} =        Set Variable    ${create_response.json()}[0]
    IF  ${{$collar_info['dbId'] is not None}}
        Log To Console      Created collar ${collar_info}[collarType] with ID: ${collar_info}[dbId]
        Sleep  5
    ELSE
        Fail  Cannot get collarId after creating. Collar transportId: ${collar_info}[transportId]
    END    
    RETURN    ${collar_info}

Create New Collar With Metadata
    [Arguments]    ${farm_id}    ${expected_status}=200    &{kwargs}
    ${application_id}=          Get Farm Transport ID By Farm ID  ${farm_id}     # application_id is a farm transportId
    ${devEui} =                 Evaluate                secrets.token_hex(16)    # Generate 32 digits hex number
    ${app_type_id} =            Evaluate                random.choice(list($COLLAR_VERSIONS.keys()))
    ${nfcSn} =                  Generate Random String  10
    ${productSerialNumber} =    Evaluate            random.randint(1,4294967294)

    ${metadata} =                             Create Dictionary
    ${metadata}[serialNumber] =               Generate String With Random Length    1  16
    ${metadata}[manufacturingWorkOrder] =     Generate String With Random Length    1  16
    ${metadata}[partNumber] =                 Generate String With Random Length    1  12
    ${metadata}[partRevision] =               Generate String With Random Length    1  2
    ${metadata}[manufacturerIdNumber] =       Get Random Int64
    ${metadata}[manufacturingLineNumber] =    Get Random Int64
    ${metadata}[manufacturingDeviationId] =   Get Random Int64
    ${metadata}[manufacturingPosixTime] =     Get Random Int64
    ${metadata}[firmwareVersionBuildStamp] =  Generate String With Random Length    1  64
    ${metadata}[cpuDebugId] =                 Get Random Int64
    ${metadata}[cpuId] =                      Get Random Int64
    ${cpuUid_1} =           Evaluate          random.randint(0, 100)
    ${cpuUid_2} =           Evaluate          random.randint(0, 100)
    ${metadata}[cpuUid] =   Create List       ${cpuUid_1}  ${cpuUid_2}
    
    ${collar_info_create} =  Create Dictionary  farmApplicationId=${application_id}
    ...                                         devEui=${devEui}
    ...                                         applicationTypeId=${app_type_id}
    ...                                         nfcSn=${nfcSn}
    ...                                         metadata=${metadata}

    FOR    ${key}    IN    @{kwargs}
        IF  isinstance($kwargs['${key}'], dict)
            Evaluate    $collar_info_create[$key].update($kwargs[$key])
        ELSE  
            ${collar_info_create}[${key}] =    Set Variable    ${kwargs}[${key}]
        END        
    END
    
    ${response} =  Do API call     POST       ${COLLAR_URL}/metadata    json=${collar_info_create}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created collar ${response.json()}[protocolVersion] with ID: ${response.json()}[id]
        # Load collar into simulator
        ${simulated_collars} =  Get Parallel Value For Key   $CREATED_COLLARS_TRANSPORT_ID        
        IF  '${response.json()}[transportId]' not in @{simulated_collars}
            ${latitude} =           Evaluate            random.uniform(-90, 90)
            ${longitude} =          Evaluate            random.uniform(-180, 180)
            ${collar_info} =        Create Dictionary   transportId=${response.json()}[transportId]
            ...                                         type=${collar_info_create}[applicationTypeId]
            ...                                         applicationId=${collar_info_create}[farmApplicationId]
            ...                                         latitude=${latitude}
            ...                                         longitude=${longitude}
            Create New Collar In Simulator From DB      ${collar_info}
        END
    END    
    RETURN    ${response}

Get Collar Metadata
    [Documentation]    Get collar metadata by transportId. Return type: response
    [Arguments]       ${expected_status}=200       &{request_params}
    
    ${response} =   Do API call      GET     ${COLLAR_URL}/metadata     params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Collars
    [Arguments]    ${expected_status}=200    &{request_params}
    ${response} =   Do API call      GET     ${COLLAR_URL}     params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Collar By ID
    [Arguments]    ${collar_id}    ${expected_status}=200
    ${response} =   Do API call      GET     ${COLLAR_URL}/${collar_id}    expected_status=${expected_status}
    RETURN    ${response}

Get Collars List By IDs
    [Arguments]    ${collar_ids}    ${expected_status}=200    &{request_params}
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ${response} =  Do API call     POST       ${COLLAR_URL}/id    params=${request_params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Update Collar By Id
    [Arguments]    ${collar_id}    ${expected_status}=200    &{kwargs}
    ${info_response} =    Get Collar By ID  collar_id=${collar_id}
    # Update collar
    ${collar_info} =      Set Variable      ${info_response.json()}
    FOR    ${key}    IN    @{kwargs}
        ${collar_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =    Do API call    PUT    ${COLLAR_URL}/${collar_id}    json=${collar_info}    expected_status=${expected_status}
    RETURN    ${response}

Update Collars Battery
    [Arguments]    ${collar_ids}    ${installTime}    ${expected_status}=204
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ...                                       batteryInstallTimePosix=${installTime}
    ${response} =  Do API call     POST       ${COLLAR_URL}/install    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Update Management State
    [Arguments]    ${farm_id}    ${collar_ids}    ${state}    ${expected_status}=200
    ${params} =    Create Dictionary          farmId=${farm_id}
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ...                                       state=${state}
    ${response} =      Do API call     POST       ${COLLAR_URL}/updateManagementState    params=${params}    json=${body}    expected_status=${expected_status}
    IF  '${expected_status}'=='200'
        ${timeout}=            Set Variable   ${40}
        ${request_interval} =  Set Variable   ${2}
        ${time_elapsed} =      Set Variable   ${0}
        WHILE  ${time_elapsed}<=${timeout}
            ${collars_updated} =   Set Variable   ${True}
            FOR  ${collar_id}  IN  @{collar_ids}
                ${collar_info} =   Get Collar By ID   ${collar_id}
                IF  '${collar_info.json()}[managementState]'!='${state}'
                    ${collars_updated} =   Set Variable   ${False}
                    Log To Console    managementState is not updated yet
                    Sleep     ${request_interval}
                    ${time_elapsed} =  Evaluate    ${time_elapsed}+${request_interval}
                    BREAK
                END
            END
            IF  ${collars_updated}
                RETURN  ${response}
            END
        END
        Fail    managementState is not updated in time. Timeout: ${timeout}
    ELSE
        RETURN  ${response}
    END

Deactivate Collars By IDs
    [Arguments]    ${farm_id}    ${collar_ids}    ${expected_status}=204
    ${params} =    Create Dictionary          farmId=${farm_id}
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ${response} =  Do API call     POST       ${COLLAR_URL}/deactivate    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Deactivate Collar By ID
    [Arguments]    ${collar_id}    ${expected_status}=200
    ${response} =  Do API call     POST       ${COLLAR_URL}/${collar_id}/deactivate    expected_status=${expected_status}
    RETURN         ${response}

Clear Queue
    [Arguments]    ${farm_id}    ${collar_ids}    ${expected_status}=200
    ${params} =    Create Dictionary          farmId=${farm_id}
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ${response} =  Do API call     POST       ${COLLAR_URL}s/clearQueue    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Clear Queue By ID
    [Arguments]    ${collar_id}    ${expected_status}=204
    ${response} =  Do API call     DELETE     ${COLLAR_URL}/${collar_id}/message    expected_status=${expected_status}
    RETURN         ${response}

Clear Memory By ID
    [Arguments]    ${collar_id}    ${expected_status}=204
    ${response} =  Do API call     DELETE     ${COLLAR_URL}/${collar_id}/memory    expected_status=${expected_status}
    RETURN         ${response}

Get Collar History By ID
    [Arguments]    ${collar_id}    ${expected_status}=200    &{request_params}
    ${response} =  Do API call     GET        ${COLLAR_URL}/${collar_id}/history   params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Collar History CSV By ID
    [Arguments]    ${collar_id}    ${expected_status}=200    &{request_params}
    ${response} =  Do API call     GET        ${COLLAR_URL}/${collar_id}/history/csv   params=${request_params}    expected_status=${expected_status}
    RETURN    ${response}

Get Collar Memory By ID
    [Arguments]    ${collar_id}    ${expected_status}=200
    ${response} =  Do API call     GET        ${COLLAR_URL}/${collar_id}/memory   expected_status=${expected_status}
    RETURN    ${response}

Get Collar Message By ID
    [Arguments]    ${collar_id}    ${expected_status}=200
    ${response} =  Do API call     GET        ${COLLAR_URL}/${collar_id}/message   expected_status=${expected_status}
    RETURN    ${response}

Resync Collar By ID
    [Arguments]    ${collar_id}    ${expected_status}=204
    ${response} =  Do API call     POST     ${COLLAR_URL}/${collar_id}/resync    expected_status=${expected_status}
    RETURN         ${response}

Resync Collars By IDs
    [Arguments]    ${farm_id}    ${collar_ids}    ${expected_status}=200
    ${params} =    Create Dictionary          farmId=${farm_id}
    ${body} =      Create Dictionary          collarIds=${collar_ids}
    ${response} =  Do API call     POST       ${COLLAR_URL}s/resync    params=${params}    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Retry Sync Collar By ID
    [Arguments]    ${collar_id}    ${expected_status}=204
    ${response} =  Do API call     POST     ${COLLAR_URL}/${collar_id}/retry    expected_status=${expected_status}
    RETURN         ${response}

Complete Logic For Collar By ID
    [Arguments]    ${collar_id}    ${expected_status}=200
    ${response} =  Do API call     POST     ${COLLAR_URL}/${collar_id}/complete    expected_status=${expected_status}
    RETURN         ${response}

Update State By Collar ID
    [Arguments]    ${collar_id}    ${state}    ${expected_status}=204
    ${body} =      Create Dictionary        state=${state}
    ${response} =  Do API call     POST     ${COLLAR_URL}/${collar_id}/state    json=${body}    expected_status=${expected_status}
    RETURN         ${response}

Generate Synchronization Error
    [Arguments]    ${collar_id}    ${expected_status}=204
    ${response} =  Do API call     POST     ${COLLAR_URL}/${collar_id}/error    expected_status=${expected_status}
    RETURN         ${response}

Update Collar Sound And Shock
    [Arguments]    ${collar_id}    ${soundEnabled}    ${shockEnabled}
    Send setCrmConfig Message      collar_id=${collar_id}
    ...                            soundEnabled=${soundEnabled}
    ...                            shockEnabled=${shockEnabled}
    ...                            hapticsEnabled=NOP
    ...                            disableSoundOnShockDisabledEnabled=NOP
    ...                            fullConfig=${False}
