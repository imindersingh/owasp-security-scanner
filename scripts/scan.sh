#!/usr/bin/env bash

source ./scripts/zap.sh

# Parameters
APPLICATION=$1
ENVIRONMENT=$2
SCAN=$3

PATH_TO_ENVIRONMENT=application/${APPLICATION}/env/
PATH_TO_RULES=application/${APPLICATION}/rules/
PATH_TO_REPORT=reports/
PATH_TO_CONFIG=application/${APPLICATION}/configuration/

ENVIRONMENT_FILE=${PATH_TO_ENVIRONMENT}${APPLICATION}.env.properties
CONFIG_FILE=${PATH_TO_CONFIG}${APPLICATION}.config.properties
RULES=${PATH_TO_RULES}${APPLICATION}.rules.conf

REPORT_FILENAME=${APPLICATION}_report_$(date +%Y-%m-%d_%H%M%S).html
REPORT=${PATH_TO_REPORT}${REPORT_FILENAME}

if [[ ! -d application/${APPLICATION} ]]; then
    if [[ ${APPLICATION} == *apple* ]]; then
        PATH_TO_ENVIRONMENT=application/apple/env/
        ENVIRONMENT_FILE=${PATH_TO_ENVIRONMENT}${APPLICATION}.env.properties
        PATH_TO_CONFIG=application/apple/configuration/
        CONFIG_FILE=${PATH_TO_CONFIG}${APPLICATION}.config.properties
        PATH_TO_RULES=application/apple/rules/
        RULES=${PATH_TO_RULES}apple.rules.conf
    else
        echo application directory not found
        exit 1
    fi
fi

# Get Target URL for Environment
if test -e ${ENVIRONMENT_FILE}; then
    TARGET_URL=`grep -w -i ${ENVIRONMENT} ${ENVIRONMENT_FILE} | awk -F "=" '{print $2}' | tail -n1`
else
    echo ${ENVIRONMENT_FILE} not found
    exit 1
fi

# Validate Target URL
if test -z ${TARGET_URL}; then
    echo Target URL for environment ${ENVIRONMENT} could not be extracted from ${ENVIRONMENT_FILE}; exit 1
else
    echo Target URL for the scan is ${TARGET_URL}
fi

# Create report directory and set permissions
mkdir -p $(PWD)/${PATH_TO_REPORT}
chmod 777 $(PWD)/${PATH_TO_REPORT}

# Run Zap scan
runScan ${APPLICATION} ${TARGET_URL} ${RULES} ${REPORT} ${CONFIG_FILE} ${SCAN}

if [[ $? -ne 1 ]]; then
    echo Scan completed successfully and PASSED with possible WARNINGS. See ${REPORT_FILENAME} for details
    exit 0
else
    echo Scan completed successfully and FAILED due to vulnerabilities found. See ${REPORT_FILENAME} for details
    exit 1
fi