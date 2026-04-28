#!/bin/bash

PORT_VALUE=${PORT:-5006}
DOMAIN_VALUE=${DOMAIN:-*}
WEBSOCKET_ORIGINS=${DOMAIN_VALUE}
if [ -n "${BOKEH_ALLOW_WS_ORIGIN}" ]; then
	WEBSOCKET_ORIGINS="${WEBSOCKET_ORIGINS},${BOKEH_ALLOW_WS_ORIGIN}"
fi

WORK_PATH=/opt/service
DATA_PATH=${WORK_PATH}/data

# app setup
if [ ! -d ${DATA_PATH} ]; then
	mkdir -p ${DATA_PATH}
fi

# setup_db.py creates missing tables and performs in-place schema upgrades
python3 ${WORK_PATH}/setup_db.py

if [ -n "${USE_PROXY}" ]; then
	echo "Use Proxy!"
	ALLOW_WS_ORIGIN_ARGS=()
	IFS=', ' read -r -a WS_ORIGINS <<< "${WEBSOCKET_ORIGINS}"
	for ORIGIN in "${WS_ORIGINS[@]}"; do
		if [ -n "${ORIGIN}" ]; then
			ALLOW_WS_ORIGIN_ARGS+=(--allow-websocket-origin="${ORIGIN}")
		fi
	done
	python3 ${WORK_PATH}/serve.py \
		--port=${PORT_VALUE} \
		--address=0.0.0.0 \
		"${ALLOW_WS_ORIGIN_ARGS[@]}" \
		--use-xheaders
else
	python3 ${WORK_PATH}/serve.py --port=${PORT_VALUE}
fi
