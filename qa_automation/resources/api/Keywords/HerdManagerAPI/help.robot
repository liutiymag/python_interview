*** Settings ***
Resource      ../CommonAPI.robot

*** Variables ***
${HELP_URL} =  ${BASE_URL_API}/help

*** Keywords ***
POST Context Help
    [Arguments]    ${expected_status}=204
    ${response} =  Do API call     POST      ${HELP_URL}    expected_status=${expected_status}
    RETURN         ${response}

Get Context Help
    [Arguments]    ${expected_status}=200
    ${response} =  Do API call     GET      ${HELP_URL}    expected_status=${expected_status}
    RETURN         ${response}

Update Context Help By Section
    [Arguments]    ${section_name}    ${expected_status}=200    &{kwargs}
    ${sections} =  Get Context Help
    ${section_body} =    Create Dictionary
    FOR  ${section}  IN  @{sections.json()}
        IF  '${section}[section]'=='${section_name}'
            ${section_body} =     Set Variable    ${section}
            BREAK
        END        
    END
    
    FOR    ${key}    IN    @{kwargs}
        ${section_body}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =  Do API call    PUT    ${HELP_URL}/section/${section_name}    json=${section_body}    expected_status=${expected_status}
    RETURN    ${response}

Update Context Help By Section ID
    [Arguments]    ${section_id}    ${expected_status}=200    &{kwargs}
    ${sections} =  Get Context Help
    ${section_body} =    Create Dictionary
    FOR  ${section}  IN  @{sections.json()}
        IF  '${section}[id]'=='${section_id}'
            ${section_body} =     Set Variable    ${section}
            BREAK
        END        
    END
    
    FOR    ${key}    IN    @{kwargs}
        ${section_body}[${key}] =    Set Variable    ${kwargs}[${key}]
    END
    ${response} =  Do API call    PUT    ${HELP_URL}/${section_id}    json=${section_body}    expected_status=${expected_status}
    RETURN    ${response}

Set Section Status Active
    [Arguments]    ${section_name}
    # Set section status ACTIVE
    ${update_response} =   Update Context Help By Section    ${section_name}    status=ACTIVE
    # Check status is ACTIVE
    ${resp} =              Get Context Help
    ${section_found} =     Set Variable                      ${False}
    FOR  ${section}  IN  @{resp.json()}
        IF  '${section}[section]'=='${section_name}'
            ${section_found} =     Set Variable              ${True}
            Should Be Equal As Strings    ${section}[status]    ACTIVE    Section ${section}[section] is not ACTIVE.
        END
    END
    Should Be True    ${section_found}    Section ${section_name} not found.
