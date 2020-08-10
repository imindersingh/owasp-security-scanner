#!/usr/bin/env bash

runScan(){
APPLICATION=$1
TARGET_URL=$2
RULES=$3
REPORT=$4
CONFIG_FILE=$5
SCAN=$6

CONFIG_PARAMETER="-configfile /zap/wrk/${CONFIG_FILE}"

BASELINE_SCAN=" \
     -v $(pwd):/zap/wrk/:rw owasp/zap2docker-weekly zap-baseline.py \
     -t ${TARGET_URL} \
     -c ${RULES} \
     -r ${REPORT} \
     -j \
     -d"

BASELINE_API_SCAN=" \
     -v $(pwd):/zap/wrk/:rw owasp/zap2docker-weekly zap-api-scan.py \
     -t ${TARGET_URL} \
     -f openapi \
     -c ${RULES} \
     -r ${REPORT} \
     -d"

ACTIVE_SCAN=" \
     -v $(pwd):/zap/wrk/:rw owasp/zap2docker-weekly zap-full-scan.py \
     -t ${TARGET_URL} \
     -c ${RULES} \
     -r ${REPORT} \
     -j \
     -d"

if [[ ${APPLICATION} == *apple* ]];then
    wGetSwagger ${TARGET_URL} ${APPLICATION}
fi

if [[ ${APPLICATION} == demo ]];then
    echo stopping existing juice-shop
    removeJuiceShop
    echo running juice-shop on http:localhost:3000
    docker run -d -p 3000:3000 bkimminich/juice-shop
fi

if [[ ${SCAN} == active ]]; then
    runDockerScan ${CONFIG_FILE} "${ACTIVE_SCAN}" "${CONFIG_PARAMETER}"
elif [[ ${SCAN} == baseline ]]; then
    runDockerScan ${CONFIG_FILE} "${BASELINE_SCAN}" "${CONFIG_PARAMETER}"
elif [[ ${SCAN} == api ]]; then
    runDockerScan ${CONFIG_FILE} "${BASELINE_API_SCAN}" "${CONFIG_PARAMETER}"
else echo scan type does not exist. Options are active, baseline or api
fi

removeJuiceShop

return $?
}

removeJuiceShop(){
ID=$(docker ps -q --filter ancestor="bkimminich/juice-shop")
if [[ -z ${ID} ]]; then
    echo juice-shop is not running
else
    echo removing juice-shop
    docker rm -f ${ID} || true
fi
}

runDockerScan(){
CONFIG_FILE=$1
SCAN=$2
CONFIG_PARAMETER=$3

if [[ -s ${CONFIG_FILE} ]]; then
    docker run ${SCAN} "-z ${CONFIG_PARAMETER}"
else
    docker run ${SCAN}
fi
}

wGetSwagger(){
TARGET_URl=$1
APPLICATION=$2

echo Deleting existing swagger files in ${PWD}
find ${PWD} -type f -name '*swagger*' -delete
echo Finished Deleting existing swagger files in ${PWD}

wget -P ${PWD} ${TARGET_URL}

if [[ -e `find ${PWD} -type f -name '*swagger*'` ]]; then
    if [[ ${APPLICATION} == *apple* ]]; then
    TARGET_URL=swagger.yml
    echo ${APPLICATION} target url has been set to ${TARGET_URL}
    fi
else
    echo swagger not found
    exit 1
fi
}