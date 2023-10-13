from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("7.1.0")

# DATASETS = ['posneg', 'spatial_multi', 'publicdb']
DATASETS = 'posneg'
GW_PARAMETERS = ['1E+8','1E+9','1E+10','1E+11','1E+12','1E+13','1E+14']
OTT_GW_PARAMETERS = ['1E+9','1E+11','1E+13']
SVD_PARAMETERS = ['0','1E+9','1E+11','1E+13']
NMF_PARAMETERS = ['0','1E+9','1E+11','1E+13']

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
		expand('plot/{data}/gw/{gwp}/finish',
			data=DATASETS, gwp=GW_PARAMETERS),
		expand('plot/{data}/ott_gw/{ott_gwp}/finish',
			data=DATASETS, ott_gwp=OTT_GW_PARAMETERS),
		expand('plot/{data}/svd/{svdp}/finish',
			data=DATASETS, svdp=SVD_PARAMETERS),
		expand('plot/{data}/nmf/{nmfp}/finish',
			data=DATASETS, nmfp=NMF_PARAMETERS)

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
# Gromov-Wasserstein
#################################
rule gw:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt'
	output:
		'output/{data}/gw/{gwp}/plan.txt',
		'output/{data}/gw/{gwp}/test_transported.txt',
		'output/{data}/gw/{gwp}/train_transported.txt'
	container:
		'docker://koki/ot-experiments:20230925'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_gw_{gwp}.txt'
	log:
		'logs/{data}_gw_{gwp}.log'
	shell:
		'src/gw.sh {input} {output} {wildcards.gwp} >& {log}'

#################################
# Optimal Tensor Transport
#################################
rule ott_gw:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt'
	output:
		'output/{data}/ott_gw/{ott_gwp}/plan.txt',
		'output/{data}/ott_gw/{ott_gwp}/test_transported.txt',
		'output/{data}/ott_gw/{ott_gwp}/train_transported.txt'
	container:
		'docker://koki/ott:20231012'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_ott_gw_{ott_gwp}.txt'
	log:
		'logs/{data}_ott_gw_{ott_gwp}.log'
	shell:
		'src/ott_gw.sh {input} {output} {wildcards.ott_gwp} >& {log}'

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
# Plot
#################################
rule plot_gw:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'output/{data}/gw/{gwp}/plan.txt',
		'output/{data}/gw/{gwp}/test_transported.txt',
		'output/{data}/gw/{gwp}/train_transported.txt'
	output:
		'plot/{data}/gw/{gwp}/finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_gw_{gwp}.txt'
	log:
		'logs/plot_ot_{data}_gw_{gwp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_ott_gw:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'output/{data}/ott_gw/{ott_gwp}/plan.txt',
		'output/{data}/ott_gw/{ott_gwp}/test_transported.txt',
		'output/{data}/ott_gw/{ott_gwp}/train_transported.txt'
	output:
		'plot/{data}/ott_gw/{ott_gwp}/finish'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_ott_gw_{ott_gwp}.txt'
	log:
		'logs/plot_ot_{data}_ott_gw_{ott_gwp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

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
		'src/plot_ot.sh {input} {output} >& {log}'

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
		'src/plot_ot.sh {input} {output} >& {log}'