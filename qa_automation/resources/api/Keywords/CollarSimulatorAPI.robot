*** Settings ***
Library       String
Library       Collections
Library       pabot.pabotlib
Library       RequestsLibrary
Library       ../../../libs/utils.py

Resource      ../../EnvVariablesData.robot
Resource      ./../Variables/alert.robot

*** Variables ***
${COLLAR_SIMULATOR_URL} =    ${COLLAR_SIMULATOR_URL_API}/api

*** Keywords ***
Create New Collar In Simulator
    [Arguments]    ${collar_info}
    ${CorrelationId} =                Generate UUID
    ${params} =                       Create Dictionary             timeout=20
    ${headers} =                      Create Dictionary             Correlationid=${CorrelationId}
    ${collar_info}[devEui] =          Convert To Upper Case         ${collar_info}[devEui]
    ${collar_info}[highPriority] =    Set Variable                  ${True}
    ${response} =           POST      ${COLLAR_SIMULATOR_URL}/collar/createGroupSync    params=${params}    json=${collar_info}    headers=${headers}    expected_status=200
    
    Acquire Lock              Update CREATED_COLLARS_TRANSPORT_ID
    ${created_collars} =      Get Parallel Value For Key   $CREATED_COLLARS_TRANSPORT_ID
    FOR  ${collar}  IN  @{response.json()}
        Append To List        ${created_collars}       ${collar}[transportId]
    END
    Set Parallel Value For Key    $CREATED_COLLARS_TRANSPORT_ID      ${created_collars}
    Release Lock                  Update CREATED_COLLARS_TRANSPORT_ID
    RETURN    ${response}

Create New Collar In Simulator From DB
    [Arguments]     ${collar_info}
    ${CorrelationId} =     Generate UUID
    ${headers} =           Create Dictionary    Correlationid=${CorrelationId}
    ${collars_list} =      Create List          ${collar_info}
    ${body} =              Create Dictionary    collars=${collars_list}
    ${response} =  POST    ${COLLAR_SIMULATOR_URL}/collar/createFromDb    json=${body}    headers=${headers}    expected_status=200
    
    Acquire Lock           Update CREATED_COLLARS_TRANSPORT_ID
    ${created_collars} =   Get Parallel Value For Key   $CREATED_COLLARS_TRANSPORT_ID
    Append To List         ${created_collars}           ${collar_info}[transportId]
    Set Parallel Value For Key    $CREATED_COLLARS_TRANSPORT_ID      ${created_collars}
    Release Lock           Update CREATED_COLLARS_TRANSPORT_ID

Create Collar Alert In Simulator
    [Arguments]    ${transportId}    ${APIalertsList}=${None}    
    &{body} =           Create Dictionary
    IF  ${APIalertsList}!=${None}
        FOR  ${key}  IN  @{APIalertsList}
            ${body}[${key}] =    Set Variable    ${True}
        END
    ELSE
        ${alert_types} =    Get Dictionary Keys    ${ALERT_TYPES}
        FOR  ${key}  IN  @{alert_types}
            ${body}[${key}] =    Set Variable    ${True}
        END
    END
    
    ${body}[sequenceNumber] =     Evaluate           str(random.randint(0, 255))
    ${transportId} =              Convert To Lower Case    ${transportId}
    
    ${CorrelationId} =            Generate UUID
    ${headers} =                  Create Dictionary  Correlationid=${CorrelationId}
    POST      ${COLLAR_SIMULATOR_URL}/send/${transportId}/alert    json=${body}    headers=${headers}    expected_status=200

Delete Collar By Transport ID
    [Arguments]    ${transportId}    ${expected_status}=any
    ${CorrelationId} =    Generate UUID
    ${headers} =          Create Dictionary  Correlationid=${CorrelationId}
    ${response} =         DELETE      ${COLLAR_SIMULATOR_URL}/collar/${transportId}    headers=${headers}    expected_status=${expected_status}
    Log To Console        API call: DELETE ${response.url}
    RETURN    ${response}

Update Collar Configuration
    [Arguments]    ${transportId}    &{kwargs}
    ${CorrelationId} =    Generate UUID
    ${headers} =          Create Dictionary  Correlationid=${CorrelationId}
    ${response} =         PUT      ${COLLAR_SIMULATOR_URL}/collar/${transportId}/configuration    headers=${headers}    json=${kwargs}    expected_status=200
    RETURN    ${response}

Update Configuration
    [Arguments]    &{kwargs}
    ${CorrelationId} =    Generate UUID
    ${headers} =          Create Dictionary  Correlationid=${CorrelationId}
    ${response} =         PUT      ${COLLAR_SIMULATOR_URL}/configuration    headers=${headers}    json=${kwargs}    expected_status=204
    RETURN    ${response}

Create Grazing Data By Landmark
    [Arguments]    &{kwargs}
    ${CorrelationId} =    Generate UUID
    ${headers} =          Create Dictionary  Correlationid=${CorrelationId}
    ${response} =         POST      ${COLLAR_SIMULATOR_URL}/grazing/createDataByLandmark    headers=${headers}    json=${kwargs}    expected_status=200
    RETURN    ${response}

Get Grazing Generation Status
    [Arguments]    ${processId}
    ${CorrelationId} =    Generate UUID
    ${headers} =          Create Dictionary  Correlationid=${CorrelationId}
    ${response} =         GET      ${COLLAR_SIMULATOR_URL}/grazing/generation/${processId}    headers=${headers}    expected_status=200
    RETURN    ${response}

Generate Grazing By Landmark
    [Arguments]    ${herdId}    ${landmarkId}    ${total_points}=${500}    ${start_date}=${None}    ${end_date}=${None}
    IF  ${start_date} == ${None}
        ${start_date} =     Evaluate       int(time.time())-15000
    END
    IF  ${end_date} == ${None}
        ${end_date} =       Evaluate       int(time.time())+55000
    END
    ${response} =       Create Grazing Data By Landmark    herdId=${herdId}
    ...                                                    landmarkId=${landmarkId}
    ...                                                    startDate=${start_date}
    ...                                                    endDate=${end_date}
    ...                                                    totalPoints=${total_points}
    # Wait untill data is created
    FOR  ${indx}  IN RANGE  30
        ${status_resp} =  Get Grazing Generation Status    ${response.json()}[id]
        IF  '${status_resp.json()}[status]' == 'COMPLETE'
            RETURN
        ELSE
            Sleep    2
        END
    END
    Fail    Grazing data generation is not completed

Set Collar Status Indication
    [Documentation]  Set device status indication. Return type: response.
    [Arguments]    ${transport_id}    &{kwargs}
    ${CorrelationId} =       Generate UUID
    ${headers} =             Create Dictionary  Correlationid=${CorrelationId}
    ${timestamp} =           Evaluate           datetime.datetime.fromtimestamp(time.time()).strftime("%Y-%m-%dT%H:%M")
    ${slot_TrackingState} =  Evaluate           ["BASIC_TRACKING" for i in range(16)]
    ${body} =                Create Dictionary  sequenceNumber=${0}
    ...                                         trackingState=BASIC_TRACKING
    ...                                         headingReportingEnabled=${False}
    ...                                         headingManagementEnabled=${False}
    ...                                         soundDisabled=${False}
    ...                                         shockDisabled=${False}
    ...                                         soundSuspended=${False}
    ...                                         shockSuspended=${False}
    ...                                         soundEvent=${False}
    ...                                         shockEvent=${False}
    ...                                         shockCountAttempts=${0}
    ...                                         soundCountAttempts=${0}
    ...                                         shockCountApplied=${0}
    ...                                         soundCountApplied=${0}
    ...                                         shockCountSuspend=${0}
    ...                                         soundCountSuspend=${0}
    ...                                         shockCountCumulative=${0}
    ...                                         currVoltageMv=${0}
    ...                                         lastTxVoltageMv=${0}
    ...                                         lastShockVoltageMv=${0}
    ...                                         mmuTempDegC=${0}
    ...                                         mcuTempDegC=${0}
    ...                                         posixTime=${timestamp}
    ...                                         slotTrackingState=${slot_TrackingState}

    FOR    ${key}    IN    @{kwargs}
        ${body}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =         POST      ${COLLAR_SIMULATOR_URL}/send/${transport_id}/deviceStatus    headers=${headers}    json=${body}    expected_status=200
    RETURN    ${response}
