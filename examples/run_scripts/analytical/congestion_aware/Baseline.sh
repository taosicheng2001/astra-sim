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
NETWORK="${EXAMPLE_DIR:?}/network/analytical/CM384Aware_Baseline.yml"
REMOTE_MEMORY="${EXAMPLE_DIR:?}/remote_memory/analytical/no_memory_expansion.json"

LLMNAME=(
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp192_sp1_ep1_dp1_pp4"  
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp384_sp1_ep1_dp2_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp48_sp1_ep1_dp1_pp16" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp8_sp2_ep4_dp2_pp6" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp96_sp1_ep8_dp1_pp1"
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp192_sp1_ep1_dp4_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp384_sp2_ep1_dp1_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp768_sp1_ep1_dp1_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp8_sp1_ep8_dp2_pp6"
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp192_sp4_ep1_dp1_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp48_sp1_ep16_dp1_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp8_sp1_ep16_dp1_pp6" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp96_sp1_ep1_dp1_pp8"
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp384_sp1_ep1_dp1_pp2" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp48_sp1_ep1_dp16_pp1" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp8_sp1_ep4_dp4_pp6" 
    "Llama4-Scout-FSDP/tp-sp-ep-dp-pp/tp96_sp1_ep1_dp8_pp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp192_sp1_ep1_pp1_dp4"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp384_sp1_ep1_pp2_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp48_sp1_ep1_pp1_dp16"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp8_sp1_ep8_pp6_dp2"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp96_sp1_ep8_pp1_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp192_sp1_ep1_pp4_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp384_sp2_ep1_pp1_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp768_sp1_ep1_pp1_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp8_sp2_ep4_pp6_dp2"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp192_sp4_ep1_pp1_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp48_sp1_ep16_pp1_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp8_sp1_ep16_pp6_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp96_sp1_ep1_pp1_dp8"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp384_sp1_ep1_pp1_dp2"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp48_sp1_ep1_pp16_dp1"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp8_sp1_ep4_pp6_dp4"
    "Llama4-Scout-FSDP/tp-sp-ep-pp-dp/tp96_sp1_ep1_pp8_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp192_sp1_pp1_ep1_dp4"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp384_sp1_pp2_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp48_sp1_pp1_ep1_dp16"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp8_sp1_pp6_ep8_dp2"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp96_sp1_pp1_ep8_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp192_sp1_pp4_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp384_sp2_pp1_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp768_sp1_pp1_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp8_sp2_pp6_ep4_dp2"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp192_sp4_pp1_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp48_sp1_pp1_ep16_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp8_sp1_pp6_ep16_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp96_sp1_pp1_ep1_dp8"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp384_sp1_pp1_ep1_dp2"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp48_sp1_pp16_ep1_dp1"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp8_sp1_pp6_ep4_dp4"
    "Llama4-Scout-FSDP/tp-sp-pp-ep-dp/tp96_sp1_pp8_ep1_dp1"    
)

# Create logs directory if it doesn't exist
LOGS_DIR="${SCRIPT_DIR}/Logs-CongestionAware/Baseline"
mkdir -p "${LOGS_DIR}"

# Export variables needed by the parallel command
export PROJECT_DIR
export EXAMPLE_DIR
export ASTRA_SIM
export SYSTEM
export NETWORK
export REMOTE_MEMORY
export LOGS_DIR

# Define function to run a single configuration
run_config() {
    local LLMNAME=$1
    local WORKLOAD="${EXAMPLE_DIR}/../traces/${LLMNAME}/WorkTrace"
    local COMM_GROUP_CONFIGURATION="${EXAMPLE_DIR}/../traces/${LLMNAME}/WorkTrace.json"
        
    echo "Running configuration: ${LLMNAME}"
    
    "${ASTRA_SIM}" \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${NETWORK}" \
        --remote-memory-configuration="${REMOTE_MEMORY}" \
        --comm-group-configuration="${COMM_GROUP_CONFIGURATION}" \
        > "${LOGS_DIR}/${LLMNAME}.log" 2>&1
    
    echo "Completed: ${LLMNAME}"
}

# Export the function so parallel can use it
export -f run_config

# remove all files in the logs directory
rm "${LOGS_DIR}/$(dirname "${LLMNAME[0]}")"/*

# Run all configurations in parallel
printf '%s\n' "${LLMNAME[@]}" | parallel -j 20 run_config {}

echo "All configurations completed. Logs are in ${LOGS_DIR}"