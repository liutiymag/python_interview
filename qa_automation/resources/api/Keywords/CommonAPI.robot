*** Settings ***
Library       Collections
Library       pabot.pabotlib
Library       RequestsLibrary
Library       ../../../libs/utils.py

Resource      ./CommonDB.robot
Resource      ./CollarSimulatorAPI.robot
Resource      ../Variables/timezones.robot

*** Variables ***
&{SECRET_PROJECT_USER_CREDENTIALS} =    username=${API_SECRET_PROJECT_USER_EMAIL}    password=${API_SECRET_PROJECT_USER_PASSWORD}
${TEST_API_TOKEN} =   ${None}    # API token of specific user role used in current test

*** Keywords ***
Create API Session
    [Documentation]     Open API session with specified name
    Acquire Lock        Create API Session
    ${token} =          Get Parallel Value For Key    $SECRET_PROJECT_USER_TOKEN
    IF  "${token}"=="${EMPTY}"        
        Evaluate                      urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)    urllib3
        # Get SECRET_PROJECT user token
        Log To Console                Create API Session token
        ${CorrelationId} =            Generate UUID
        ${headers} =                  Create Dictionary              Correlationid=${CorrelationId}
        ${response} =                 POST                           ${BASE_URL_API}/login     json=${SECRET_PROJECT_USER_CREDENTIALS}    headers=${headers}    expected_status=200
        Set Parallel Value For Key    $SECRET_PROJECT_USER_TOKEN              ${response.headers}[Authorization]
        ${empty_enterprises_list} =   Create List
        Set Parallel Value For Key    $CREATED_ENTERPRISES_ID        ${empty_enterprises_list}
        ${empty_collars_list} =       Create List
        Set Parallel Value For Key    $CREATED_COLLARS_TRANSPORT_ID  ${empty_collars_list}
        ${empty_messageGroup_list} =  Create List
        Set Parallel Value For Key    $CREATED_MESSAGE_GROUPS_ID     ${empty_messageGroup_list}
        ${empty_dict} =               Create Dictionary
        Set Parallel Value For Key    $COMMON_USERS                  ${empty_dict}        
    END
    Release Lock    Create API Session

Create API Session With Common Enterprise
    [Documentation]    Create API session with common enterprise
    Acquire Lock       Create Common Enterprise
    ${common_enterprise} =           Get Parallel Value For Key  $COMMON_ENTERPRISE_ID
    IF  "${common_enterprise}"=="${EMPTY}"        
        Log To Console               Create common enterprise
        Create API Session
        # Create common enterprise
        ${enterprise_response} =     Create Enterprise Common
        Set Parallel Value For Key   $COMMON_ENTERPRISE_ID       ${enterprise_response.json()}[id]        
    END
    Release Lock    Create Common Enterprise

Create API Session With Common Farm
    [Documentation]    Create API session with common enterprise, farm
    Acquire Lock       Create Common Farm
    ${common_farm} =   Get Parallel Value For Key   $COMMON_FARM_ID
    IF  "${common_farm}"=="${EMPTY}"
        Create API Session With Common Enterprise
        Log To Console               Create common farm
        ${enterprise_id} =           Get Parallel Value For Key     $COMMON_ENTERPRISE_ID
        # Create common farm
        ${farm_response} =           Create Farm Common             enterprise_id=${enterprise_id}
        Set Parallel Value For Key   $COMMON_FARM_ID                ${farm_response.json()}[id]        
    END
    Release Lock    Create Common Farm
    
Create API Session With Common Users
    [Documentation]    Create API session, common enterprise, farm, users
    Acquire Lock       Create Common Users
    ${com_users} =     Get Parallel Value For Key     $COMMON_USERS
    ${empty_dict} =    Create Dictionary
    IF  "${com_users}"=="${empty_dict}" or "${com_users}"=="${EMPTY}"        
        Create API Session With Common Farm
        Log To Console  Create common users
        ${farm_id} =    Get Parallel Value For Key    $COMMON_FARM_ID
        # Create Admin user
        ${admin_password}    ${admin_response} =                 Create User With Password Common    farm_id=${farm_id}   role=ROLE_ADMIN
        ${admin_credentials} =           Create Dictionary       username=${admin_response.json()}[username]    password=${admin_password}
        ${admin_login} =                 Do API call             POST    ${BASE_URL_API}/login    json=${admin_credentials}
        ${admin_credentials}[token] =    Set Variable            ${admin_login.headers}[Authorization]
        # Create Manager user
        ${manager_password}    ${manager_response} =             Create User With Password Common    farm_id=${farm_id}   role=ROLE_MANAGER
        ${manager_credentials} =         Create Dictionary       username=${manager_response.json()}[username]    password=${manager_password}
        ${manager_login} =               Do API call             POST    ${BASE_URL_API}/login    json=${manager_credentials}
        ${manager_credentials}[token] =  Set Variable            ${manager_login.headers}[Authorization]
        # Create Regular user
        ${regular_password}    ${regular_response} =             Create User With Password Common    farm_id=${farm_id}   role=ROLE_USER
        ${regular_credentials} =         Create Dictionary       username=${regular_response.json()}[username]    password=${regular_password}
        ${regular_login} =               Do API call             POST    ${BASE_URL_API}/login    json=${regular_credentials}
        ${regular_credentials}[token] =  Set Variable            ${regular_login.headers}[Authorization]
        # Create common users dict
        ${users} =                       Create Dictionary       ROLE_ADMIN=${admin_credentials}
        ...                                                      ROLE_MANAGER=${manager_credentials}
        ...                                                      ROLE_USER=${regular_credentials}
        Set Parallel Value For Key       $COMMON_USERS           ${users}        
    END
    Release Lock    Create Common Users

Do API call
    [Documentation]       Perform API request with Correlationid header
    [Arguments]           ${http_method}    ${url}    ${params}=${None}    ${data}=${None}    ${json}=${None}    ${headers}=${None}    ${expected_status}=200    ${is_SECRET_PROJECT_user}=${False}
    ${CorrelationId} =    Generate UUID
    IF  ${{$TEST_API_TOKEN is None}} or ${is_SECRET_PROJECT_user}
        ${token} =        Get Parallel Value For Key    $SECRET_PROJECT_USER_TOKEN
        Log To Console    Using SECRET_PROJECT_USER_TOKEN
    ELSE
        ${token} =        Set Variable    ${TEST_API_TOKEN}
        Log To Console    Using TEST_API_TOKEN
    END    
    IF     ${headers} is ${None}
        ${headers} =    Create Dictionary  Correlationid=${CorrelationId}    Authorization=${token}
    ELSE           
        Set To Dictionary    ${headers}    Correlationid=${CorrelationId}    Authorization=${token}
    END
    IF         "${http_method}" == "GET"
        ${response} =    GET       ${url}    params=${params}    data=${data}    json=${json}    headers=${headers}    expected_status=${expected_status}    msg=${http_method}
    ELSE IF    "${http_method}" == "POST"
        ${response} =    POST      ${url}    params=${params}    data=${data}    json=${json}    headers=${headers}    expected_status=${expected_status}    msg=${http_method}
    ELSE IF    "${http_method}" == "PUT"
        ${response} =    PUT       ${url}    params=${params}    data=${data}    json=${json}    headers=${headers}    expected_status=${expected_status}    msg=${http_method}
    ELSE IF    "${http_method}" == "DELETE"
        ${response} =    DELETE    ${url}    params=${params}    data=${data}    json=${json}    headers=${headers}    expected_status=${expected_status}    msg=${http_method}
    END
    Log To Console    API call: ${http_method} ${response.url}
    IF  "${http_method}" == "POST" and "${url}" == "${BASE_URL_API}/enterprise" and "${response.status_code}" == "200"
        Acquire Lock                  Update CREATED_ENTERPRISES_ID
        ${created_enterprises} =      Get Parallel Value For Key   $CREATED_ENTERPRISES_ID
        Append To List                ${created_enterprises}       ${response.json()}[id]
        Set Parallel Value For Key    $CREATED_ENTERPRISES_ID      ${created_enterprises}
        Release Lock                  Update CREATED_ENTERPRISES_ID
    ELSE IF  "${http_method}" == "POST" and "${url}" == "${BASE_URL_API}/messageGroup" and "${response.status_code}" == "200"
        Acquire Lock                  Update CREATED_MESSAGE_GROUPS_ID
        ${created_messageGroups} =    Get Parallel Value For Key   $CREATED_MESSAGE_GROUPS_ID
        Append To List                ${created_messageGroups}     ${response.json()}[id]
        Set Parallel Value For Key    $CREATED_MESSAGE_GROUPS_ID   ${created_messageGroups}
        Release Lock                  Update CREATED_MESSAGE_GROUPS_ID
    END    
    RETURN    ${response}
    
Clean Up
    [Documentation]        Delete entities created during testing
    Run On Last Process    Clean Up Keyword

Clean Up Keyword
    [Documentation]    Run clean up functions one by one
    ${clean_collars_success} =        Clean Up Collars
    ${clean_enterprise_success} =     Clean Up Enterprises
    ${clean_messageGroups_success} =  Clean Up messageGroups
    Should Be True                    ${clean_enterprise_success}      Enterprise clean up is failed
    Should Be True                    ${clean_collars_success}         Collars clean up is failed
    Should Be True                    ${clean_messageGroups_success}   messageGroups clean up is failed

Clean Up Enterprises
    [Documentation]    Delete enterprises and related test entities
    Log To Console     Running Clean Up Enterprises
    ${no_errors} =            Set Variable    ${True}
    ${created_enterprises} =  Get Parallel Value For Key   $CREATED_ENTERPRISES_ID
    IF  ${{str(${created_enterprises})==''}}
        ${created_enterprises} =    Create List
    END
    FOR  ${enterprise}  IN    @{created_enterprises}
        ${body} =           Create Dictionary     enterpriseId=${enterprise}
        ${response} =       Do API call    POST   ${BASE_URL_API}/test/clearAllTables    json=${body}    expected_status=any
        IF  ${response.status_code}==200
            Log To Console    Enterprise data is deleted. ID: ${enterprise}
        ELSE IF  ${response.status_code}==504
            Log To Console    Enterprise data deletion is in progress. Got status 504. ID: ${enterprise}
        ELSE
            Log To Console  Cannot delete enterprise Id: ${enterprise}. Status code: ${response.status_code}. Error: ${response.text}
            ${no_errors} =      Set Variable    ${False}
        END
    END
    ${empty_list} =              Create List
    Set Parallel Value For Key   $CREATED_ENTERPRISES_ID  ${empty_list}    
    Set Parallel Value For Key   $COMMON_ENTERPRISE_ID    ${EMPTY}
    Set Parallel Value For Key   $COMMON_FARM_ID          ${EMPTY}
    ${empty_dict} =              Create Dictionary
    Set Parallel Value For Key   $COMMON_USERS            ${empty_dict}
    Run Keyword If    not ${no_errors}    Log To Console    Failed to clean up enterprises!    
    RETURN    ${no_errors}

Clean Up messageGroups
    [Documentation]    Delete created messageGroups
    Log To Console              Running Clean Up messageGroups
    ${no_errors} =              Set Variable                 ${True}
    ${created_messageGroups} =  Get Parallel Value For Key   $CREATED_MESSAGE_GROUPS_ID
    IF  ${{str(${created_messageGroups})==''}}
        ${created_messageGroups} =    Create List
    END
    FOR  ${messageGroup}  IN    @{created_messageGroups}
        TRY
            ${body} =           Evaluate               {'messageGroupIds': ['${messageGroup}']}
            ${response} =       Do API call    POST    ${BASE_URL_API}/test/cleanMessageGroups    json=${body}    expected_status=any        
            Status Should Be    200    ${response}     messageGroup is not deleted. ID: ${messageGroup}. Response code: ${response.status_code}. Response: ${response.text}
            Run Keyword If      ${response.status_code}==200    Log To Console    messageGroup is deleted. ID: ${messageGroup}
        EXCEPT    AS    ${error_message}
            Log To Console      Cannot delete messageGroup Id: ${messageGroup}. Error: ${error_message}
            ${no_errors} =      Set Variable    ${False}
        END
    END
    ${empty_list} =              Create List
    Set Parallel Value For Key   $CREATED_MESSAGE_GROUPS_ID  ${empty_list}   
    Run Keyword If    not ${no_errors}    Log To Console    Failed to clean up messageGroups!    
    RETURN    ${no_errors}

Clean Up Collars
    [Documentation]    Delete collars from Collar Simulator
    Log To Console          Running Clean Up Collars
    ${no_errors} =          Set Variable    ${True}
    ${created_collars} =    Get Parallel Value For Key   $CREATED_COLLARS_TRANSPORT_ID
    IF  ${{str(${created_collars})==''}}
        ${created_collars} =    Create List
    END
    FOR  ${transport_id}  IN      @{created_collars}
        TRY
            ${response} =       Delete Collar By Transport ID    ${transport_id}    expected_status=any        
            Status Should Be    200    ${response}    Collar is not deleted. Transport ID: ${transport_id}. Response code: ${response.status_code}. Response: ${response.text}
            Run Keyword If      ${response.status_code}==200    Log To Console    Collar is deleted. Transport ID: ${transport_id}
        EXCEPT    AS     ${error_message}
            Log To Console      Cannot delete collar transportId: ${transport_id}. Error: ${error_message}
            ${no_errors} =      Set Variable    ${False}
        END
    END
    ${empty_list} =              Create List
    Set Parallel Value For Key   $CREATED_COLLARS_TRANSPORT_ID  ${empty_list}
    Run Keyword If    not ${no_errors}    Log To Console    Failed to clean up collars!
    RETURN    ${no_errors}

Run Scheduled Job
    [Documentation]    Force run of scheduled job for specific Farm
    [Arguments]        ${farm_id}    ${task_type}
    ${params} =        Create Dictionary    farmId=${farm_id}    taskType=${task_type}    
    Do API call        POST     ${BASE_URL_API}/test/runScheduledJob     params=${params}    is_SECRET_PROJECT_user=${True}    expected_status=204

Check Failure is Present
    [Documentation]         Check if specified failure is present in response
    [Arguments]             ${response_json}    ${expected_failure_key}    ${expected_fieldName}=${None}
    ${correct_failure} =    Set Variable        ${False}
    FOR    ${failure}    IN    @{response_json}[failures]
        IF     "${failure}[key]" == "${expected_failure_key}" and "${failure}[fieldName]" == "${expected_fieldName}"
            ${correct_failure} =    Set Variable    ${True}
        END
    END
    Should Be True    ${correct_failure}    Invalid error message. Expected key: "${expected_failure_key}", expected fieldName: "${expected_fieldName}". Actual response: ${response_json}

Use Specific User For API Calls
    [Documentation]    Use specified user for API calls
    [Arguments]        ${user_name}=${None}    ${user_password}=${None}    ${user_token}=${None}
    # If user token is not specified, get token for user
    IF  ${{$user_token is None}}        
        ${auth_response} =    User Login Common  ${user_name}    ${user_password}    expected_status=200
        ${token} =            Set Variable       ${auth_response.headers}[Authorization]
    ELSE
        ${token} =            Set Variable       ${user_token}
    END
    Set Test Variable         ${TEST_API_TOKEN}  ${token}

Create Enterprise Common
    [Arguments]    ${expected_status}=200    &{kwargs}
    ${random_name} =    Generate Random String    128
    ${name} =           Get From Dictionary    ${kwargs}    name    ${random_name}

    ${data} =           Create Dictionary      name=${name}
    ${response} =       Do API call    POST    ${BASE_URL_API}/enterprise    json=${data}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created enterprise with ID: ${response.json()}[id]
    END
    RETURN    ${response}

Create Farm Common
    [Arguments]    ${enterprise_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$enterprise_id is not None}}
            ${params} =    Create Dictionary    enterpriseId=${enterprise_id}
    END
    
    ${name} =                    Generate Random String    128
    ${transportId} =             Get Substring             ${name}    0    16
    ${timeZone} =                Evaluate                  random.choice(${TIMEZONES})
    ${inclusionShockWidth} =     Evaluate                  random.randint(15, 65535)
    ${inclusionSoundWidth} =     Evaluate                  random.randint(0, 65535)
    ${exclusionShockWidth} =     Evaluate                  random.randint(5, 65535)
    ${exclusionSoundWidth} =     Evaluate                  random.randint(0, 65535)
    ${movementRate} =            Evaluate                  random.uniform(0.1, 10.0)
    ${x_coord} =                 Evaluate                  random.uniform(-90, 90)
    ${y_coord} =                 Evaluate                  random.uniform(-180, 180)
    ${coordinates} =             Create List               ${y_coord}    ${x_coord}
    ${location} =                Create Dictionary         type=Point    coordinates=${coordinates}
    
    ${farm_info} =               Create Dictionary         name=${name}
    ...                                                    transportId=${transportId}
    ...                                                    location=${location}
    ...                                                    timeZone=${timeZone}
    ...                                                    inclusionShockWidth=${inclusionShockWidth}
    ...                                                    inclusionSoundWidth=${inclusionSoundWidth}
    ...                                                    exclusionShockWidth=${exclusionShockWidth}
    ...                                                    exclusionSoundWidth=${exclusionSoundWidth}
    ...                                                    movementRate=${movementRate}

    FOR    ${key}    IN    @{kwargs}
        ${farm_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =      Do API call    POST    ${BASE_URL_API}/farm    params=${params}    json=${farm_info}    expected_status=${expected_status}
    IF    ${response.status_code}==200
        Log To Console    Created farm with ID: ${response.json()}[id]
    END
    RETURN    ${response}

User Login Common
    [Arguments]    ${username}    ${password}    ${expected_status}=any
    ${data} =      Create dictionary    username=${username}    password=${password}
	${response} =  Do API call    POST    ${BASE_URL_API}/login    json=${data}    expected_status=${expected_status}
    RETURN         ${response}

Generate Username Common
    [Documentation]     Generates random username
    ${random_str} =     Generate Random String    ${24}
    ${username} =       Set Variable              test_user_${random_str}@SECRET_PROJECT.io
    RETURN  ${username}

Create User Common
    [Documentation]     Creates user with defined password
    [Arguments]         ${farm_id}=${None}    ${expected_status}=200    &{kwargs}
    ${params} =    Set Variable    ${None}
    IF    ${{$farm_id is not None}}
            ${params} =    Create Dictionary    farmId=${farm_id}
    END
    ${username} =       Generate Username Common
    ${pages} =          Create List               MANAGEMENT
    ${first_name} =     Set Variable              ${username}_firstName
    ${last_name} =      Set Variable              ${username}_lastName
    ${description} =    Generate Random String    ${256}
    ${street1} =        Generate Random String    ${128}
    ${street2} =        Generate Random String    ${128}
    ${city} =           Generate Random String    ${128}
    ${state} =          Generate Random String    ${64}
    ${zip} =            Generate Random String    ${64}    [NUMBERS]
    ${cellPhone} =      Generate Random String    ${64}    [NUMBERS]
    ${homePhone} =      Generate Random String    ${64}    [NUMBERS]
    ${timeView} =       Evaluate                  random.choice([ 'LOCAL_TIME_VIEW', 'FARM_TIME_VIEW', 'GMT_TIME_VIEW' ])
    ${user_info} =      Create Dictionary         username=${username}
    ...                                           firstName=${first_name}
    ...                                           lastName=${last_name}
    ...                                           role=ROLE_USER
    ...                                           description=${description}
    ...                                           street1=${street1}
    ...                                           street2=${street2}
    ...                                           city=${city}
    ...                                           state=${state}
    ...                                           zip=${zip}
    ...                                           cellPhone=${cellPhone}
    ...                                           homePhone=${homePhone}
    ...                                           timeView=${timeView}
    ...                                           pages=${pages}

    FOR    ${key}    IN    @{kwargs}
        ${user_info}[${key}] =    Set Variable    ${kwargs}[${key}]
    END

    # Create user
    ${response} =   Do API call      POST     ${BASE_URL_API}/user     params=${params}    json=${user_info}    expected_status=${expected_status}
    IF  ${{${response.status_code} == 200}}
        Log To Console  Created ${user_info}[role] user ${user_info}[username] with id "${response.json()}[id]"
    END
    RETURN  ${response}    

Create User With Password Common
    [Documentation]    Create user with generated password
    [Arguments]        ${farm_id}=${None}    &{kwargs}
    ${create_response} =    Create User Common    farm_id=${farm_id}    expected_status=200    &{kwargs}
    ${password} =           Generate Random String
    ${id} =                 Set Variable   ${create_response.json()}[id]
    # Set User Password in DB
    ${encrypted_password} =   bcrypt_encode_string    ${password}
    ${sql} =       Catenate   update public.SECRET_PROJECT_user
    ...                       set password='${encrypted_password}'
    ...                       where id='${id}'
    Execute SQL In DB         ${sql}
    RETURN  ${password}       ${create_response}

Get Common Farm Id
    [Documentation]    Get common farmId or raise an error if it is empty. Return type: str(uuid)
    ${farm_id} =    Get Parallel Value For Key   $COMMON_FARM_ID
    IF  "${farm_id}"=="${EMPTY}"
        Fail    Common farmId is empty.
    END
    RETURN    ${farm_id}

Get Common Enterprise Id
    [Documentation]    Get common enterpriseId or raise an error if it is empty. Return type: str(uuid)
    ${enterprise_id} =    Get Parallel Value For Key   $COMMON_ENTERPRISE_ID
    IF  "${enterprise_id}"=="${EMPTY}"
        Fail    Common enterpriseId is empty.
    END
    RETURN    ${enterprise_id}

Get Common Users
    [Documentation]    Get common users or raise an error if it is empty. Return type: dict
    ${com_users} =     Get Parallel Value For Key   $COMMON_USERS
    ${empty_dict} =    Create Dictionary
    IF  "${com_users}"=="${empty_dict}" or "${com_users}"=="${EMPTY}"
        Fail    Common users dict is empty.
    END
    RETURN    ${com_users}
