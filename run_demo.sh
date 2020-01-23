#! /bin/bash

# Copyright (C) 2016, Northwestern University
# See COPYRIGHT notice in top-level directory.

# This is a demo script

# First, specify your local matlab location 
MATLAB=/usr/local/MATLAB/R2012a/bin/glnxa64/MATLAB
# Step 1: generate data. Data will be saved in data/data_demo.dat
$MATLAB -r "run source/datagen/exp_rand_demo"
# Step 2: read data, perform variable ranking & range reduction
#	Output of Step 2 is saved at model_output/demo_modelout.mat
python source/train_model.py --input_data data/data_demo.mat --output_data model_output/demo_modelout.mat
# Step 3: read model otuput from Step 2, perform enhanced optimization
$MATLAB -r "run source/patternSearch_demo"
