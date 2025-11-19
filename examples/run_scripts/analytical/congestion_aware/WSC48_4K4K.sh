#!/bin/bash
set -e

## ******************************************************************************
## This source code is licensed under the MIT license found in the
## LICENSE file in the root directory of this source tree.
##
## Copyright (c) 2024 Georgia Institute of Technology
## ******************************************************************************

# find the absolute path to this script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_DIR="${SCRIPT_DIR:?}/../../../.."
EXAMPLE_DIR="${PROJECT_DIR:?}/examples"

# paths
ASTRA_SIM="${PROJECT_DIR:?}/build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Aware"
SYSTEM="${EXAMPLE_DIR:?}/system/native_collectives/910Die.json"
NETWORK="${EXAMPLE_DIR:?}/network/analytical/CM384Aware_WSC_48.yml"
REMOTE_MEMORY="${EXAMPLE_DIR:?}/remote_memory/analytical/no_memory_expansion.json"

LLMNAME=(
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep16_dp1_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep16_dp6_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep8_dp6_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep8_dp2_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep8_dp1_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep8_dp6_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep4_dp4_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep4_dp6_pp4"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep4_dp6_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep4_dp2_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep8_dp1_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep8_dp6_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep4_dp6_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep4_dp2_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp2_ep4_dp1_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp16_sp2_ep4_dp6_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp32_sp1_ep4_dp1_pp6"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp32_sp1_ep4_dp6_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp1_pp4"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp2_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp4_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep8_dp1_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep8_dp2_pp1"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp2_ep4_dp1_pp2"
    "Llama4-Scout-4K4K/tp-sp-ep-dp-pp/tp48_sp2_ep4_dp2_pp1"

    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep16_dp1_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep16_dp6_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep8_dp6_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep8_dp2_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep8_dp1_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep8_dp6_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep4_dp4_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp1_ep4_dp6_pp4"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep4_dp6_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp8_sp2_ep4_dp2_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep8_dp1_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep8_dp6_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep4_dp6_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp1_ep4_dp2_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp2_ep4_dp1_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp16_sp2_ep4_dp6_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp32_sp1_ep4_dp1_pp6"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp32_sp1_ep4_dp6_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp1_pp4"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp2_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep4_dp4_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep8_dp1_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp1_ep8_dp2_pp1"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp2_ep4_dp1_pp2"
    "GPT-OSS-4K4K/tp-sp-ep-dp-pp/tp48_sp2_ep4_dp2_pp1"
)

# Create logs directory if it doesn't exist
EXEC_LOGS_DIR="${SCRIPT_DIR}/Logs-CA/WSC48/"
BREAKDOWN_LOGS_DIR="${SCRIPT_DIR}/Logs-BreakingDown/WSC48/"

mkdir -p "${EXEC_LOGS_DIR}"
mkdir -p "${BREAKDOWN_LOGS_DIR}"

# Export variables needed by the parallel command
export PROJECT_DIR
export EXAMPLE_DIR
export ASTRA_SIM
export SYSTEM
export NETWORK
export REMOTE_MEMORY
export EXEC_LOGS_DIR
export BREAKDOWN_LOGS_DIR
export SCRIPT_DIR

# Define function to run a single configuration
run_config() {
    local LLMNAME=$1
    local WORKLOAD="/root/Gist/symbolic_tensor_graph/traces_4K_4K/${LLMNAME}/WorkTrace"
    local COMM_GROUP_CONFIGURATION="/root/Gist/symbolic_tensor_graph/traces_4K_4K/${LLMNAME}/WorkTrace.json"
    local EVENT_TRACKER_FILE_PATH="${BREAKDOWN_LOGS_DIR}/${LLMNAME}.event_tracker.txt"
    echo "Running configuration: ${LLMNAME}"
    
    "${ASTRA_SIM}" \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${NETWORK}" \
        --remote-memory-configuration="${REMOTE_MEMORY}" \
        --comm-group-configuration="${COMM_GROUP_CONFIGURATION}" \
        --event-tracker-file-path="${EVENT_TRACKER_FILE_PATH}" > "${EXEC_LOGS_DIR}/${LLMNAME}.log" 2>&1
    
    echo "Completed: ${LLMNAME}"
}

# Export the function so parallel can use it
export -f run_config

# Run all configurations in parallel
printf '%s\n' "${LLMNAME[@]}" | parallel -j 4 run_config {}

echo "All configurations completed. Logs are in ${EXEC_LOGS_DIR}"