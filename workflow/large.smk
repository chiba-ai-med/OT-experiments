from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("7.1.0")

DATASETS = 'large_posneg'
SVD_PARAMETERS = ['0','1E+9','1E+11','1E+13']
NMF_PARAMETERS = ['0','1E+9','1E+11','1E+13']
NMF_TD_PARAMETERS = ['0','1E+13','1E+15','1E+17']

rule all:
	input:
		expand('plot/{data}/source_test_data_finish',
			data=DATASETS),
		expand('plot/{data}/target_test_data_finish',
			data=DATASETS),
		expand('plot/{data}/source_train_data_finish',
			data=DATASETS),
		expand('plot/{data}/target_train_data_finish',
			data=DATASETS),
		expand('plot/{data}/svd/{svdp}/finish',
			data=DATASETS, svdp=SVD_PARAMETERS),
		expand('plot/{data}/nmf/{nmfp}/finish',
			data=DATASETS, nmfp=NMF_PARAMETERS),
		expand('plot/{data}/nmf_td/{nmf_tdp}/finish',
			data=DATASETS, nmf_tdp=NMF_TD_PARAMETERS)

#################################
# Data pre-processing
#################################
rule preprocess:
	output:
		'data/{data}/source_test_data.txt',
		'data/{data}/target_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/preprocess_{data}.txt'
	log:
		'logs/preprocess_{data}.log'
	shell:
		'src/preprocess_{wildcards.data}.sh {input} {output} >& {log}'

rule plot_data:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/target_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt'
	output:
		'plot/{data}/source_test_data_finish',
		'plot/{data}/target_test_data_finish',
		'plot/{data}/source_train_data_finish',
		'plot/{data}/target_train_data_finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_data_{data}.txt'
	log:
		'logs/plot_data_{data}.log'
	shell:
		'src/plot_{wildcards.data}.sh {input} {output} >& {log}'

#################################
# SVD → GW
#################################
rule svd:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt'
	output:
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/test_transported.txt',
		'output/{data}/svd/{svdp}/train_transported.txt'
	container:
		'docker://koki/ott:20231012'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_svd_{svdp}.txt'
	log:
		'logs/{data}_svd_{svdp}.log'
	shell:
		'src/svd.sh {input} {output} {wildcards.svdp} >& {log}'

#################################
# NMF → GW
#################################
rule nmf:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt'
	output:
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/test_transported.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt'
	container:
		'docker://koki/ott:20231012'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_nmf_{nmfp}.txt'
	log:
		'logs/{data}_nmf_{nmfp}.log'
	shell:
		'src/nmf.sh {input} {output} {wildcards.nmfp} >& {log}'

#################################
# NMF → GW (PyTorchDecomp)
#################################
rule nmf_td:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt'
	output:
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/test_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt'
	container:
		'docker://koki/ot-experiments-td:20240328'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_nmf_td_{nmf_tdp}.log'
	shell:
		'src/nmf_td.sh {input} {output} {wildcards.nmf_tdp} >& {log}'

#################################
# Plot
#################################
rule plot_svd:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/test_transported.txt',
		'output/{data}/svd/{svdp}/train_transported.txt'
	output:
		'plot/{data}/svd/{svdp}/finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_svd_{svdp}.txt'
	log:
		'logs/plot_ot_{data}_svd_{svdp}.log'
	shell:
		'src/plot_ot_large.sh {input} {output} >& {log}'

rule plot_nmf:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/test_transported.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt'
	output:
		'plot/{data}/nmf/{nmfp}/finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_nmf_{nmfp}.txt'
	log:
		'logs/plot_ot_{data}_nmf_{nmfp}.log'
	shell:
		'src/plot_ot_large.sh {input} {output} >& {log}'

rule plot_nmf_td:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/test_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt'
	output:
		'plot/{data}/nmf_td/{nmf_tdp}/finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/plot_ot_{data}_nmf_td_{nmf_tdp}.log'
	shell:
		'src/plot_ot_large.sh {input} {output} >& {log}'
