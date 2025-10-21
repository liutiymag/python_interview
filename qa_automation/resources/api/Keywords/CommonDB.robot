*** Settings ***
Library       DatabaseLibrary
Library       ../../../libs/crypt_utils.py

Resource      ../../../resources/EnvVariablesData.robot

*** Keywords ***
Query To DB
    [Arguments]    ${sql}
    Connect To Database       psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    @{query_results} =    Query    ${sql}
    Disconnect From Database
    RETURN    ${query_results}

Execute SQL In DB
    [Arguments]    ${sql}
    Connect To Database       psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    Execute Sql String        ${sql}
    Disconnect From Database

Disable Password Change Request in DB
    [Documentation]    Do not ask to change password during first login
    [Arguments]        ${id}    
    ${sql} =       Catenate    update public.SECRET_PROJECT_user
    ...                        set change_password=false
    ...                        where id='${id}'
    Execute SQL In DB          ${sql}
