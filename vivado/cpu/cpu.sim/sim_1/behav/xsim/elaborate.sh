#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Thu May 18 12:44:55 CST 2023
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xelab -wto f723e340fc4245dc91c84d0ee7d207c4 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot openmips_min_sopc_tb_behav xil_defaultlib.openmips_min_sopc_tb xil_defaultlib.glbl -log elaborate.log"
xelab -wto f723e340fc4245dc91c84d0ee7d207c4 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot openmips_min_sopc_tb_behav xil_defaultlib.openmips_min_sopc_tb xil_defaultlib.glbl -log elaborate.log
