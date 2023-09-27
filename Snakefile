from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("7.1.0")

# DATASETS = ['lipid', 'spatial_multi', 'visium']
DATASETS = 'lipid'
SK_PARAMETERS = ['1e+8','1e+9','1e+10','1e+11']
GWROW_PARAMETERS = ['1E+8','1E+9','1E+10','1E+11']
GWCOL_PARAMETERS = ['1E+8','1E+9','1E+10','1E+11']
COOT_PARAMETERS = ['1e+7','2e+7','3e+7','4e+7','5e+7','6e+7','7e+7','8e+7','9e+7','1e+8','1e+9']
OTTL1_PARAMETERS = ['1E+6','1E+7','1E+8','1E+9']
OTTL2_PARAMETERS = ['1E+6','1E+7','1E+8','1E+9']

rule all:
	input:
		expand('plot/{data}/source.png', data=DATASETS),
		expand('plot/{data}/target.png', data=DATASETS),
		expand('plot/{data}/sk_{skp}.png',
			data=DATASETS, skp=SK_PARAMETERS),
		expand('plot/{data}/gwrow_{gwrowp}.png',
			data=DATASETS, gwrowp=GWROW_PARAMETERS),
		expand('plot/{data}/gwcol_{gwcolp}.png',
			data=DATASETS, gwcolp=GWCOL_PARAMETERS),
		expand('plot/{data}/coot_{cootp}.png',
			data=DATASETS, cootp=COOT_PARAMETERS),
		expand('plot/{data}/ottl1_{ottl1p}.png',
			data=DATASETS, ottl1p=OTTL1_PARAMETERS),
		expand('plot/{data}/ottl2_{ottl2p}.png',
			data=DATASETS, ottl2p=OTTL2_PARAMETERS)

#################################
# Data pre-processing
#################################
rule preprocess:
	output:
		'data/{data}/vec_source.txt',
		'data/{data}/vec_target.txt',
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
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
		'data/{data}/vec_source.txt',
		'data/{data}/vec_target.txt'	
	output:
		'plot/{data}/source.png',
		'plot/{data}/target.png'	
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_data_{data}.txt'
	log:
		'logs/plot_data_{data}.log'
	shell:
		'src/plot_{wildcards.data}.sh {input} {output} >& {log}'

#################################
# Sinkhorn-Knopp
#################################
rule sk:
	input:
		'data/{data}/vec_source.txt',
		'data/{data}/vec_target.txt'
	output:
		'output/{data}/sk/{skp}/plan.txt1',
		'output/{data}/sk/{skp}/transported.txt'
	container:
		'docker://koki/ot-experiments:20230925'
	benchmark:
		'benchmarks/{data}_sk_{skp}.txt'
	log:
		'logs/{data}_sk_{skp}.log'
	shell:
		'src/sk.sh {input} {output} {wildcards.skp} >& {log}'

#################################
# Row-wise Gromov-Wasserstein
#################################
rule gwrow:
	input:
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
	output:
		'output/{data}/gwrow/{gwrowp}/plan.txt',
		'output/{data}/gwrow/{gwrowp}/transported.txt'
	container:
		'docker://koki/ot-experiments:20230925'
	benchmark:
		'benchmarks/{data}_gwrow_{gwrowp}.txt'
	log:
		'logs/{data}_gwrow_{gwrowp}.log'
	shell:
		'src/gwrow.sh {input} {output} {wildcards.gwrowp} >& {log}'

rule gwcol:
	input:
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
	output:
		'output/{data}/gwcol/{gwcolp}/plan.txt',
		'output/{data}/gwcol/{gwcolp}/transported.txt'
	container:
		'docker://koki/ot-experiments:20230925'
	benchmark:
		'benchmarks/{data}_gwcol_{gwcolp}.txt'
	log:
		'logs/{data}_gwcol_{gwcolp}.log'
	shell:
		'src/gwcol.sh {input} {output} {wildcards.gwcolp} >& {log}'

#################################
# COOT
#################################
rule coot:
	input:
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
	output:
		'output/{data}/coot/{cootp}/plan1.txt',
		'output/{data}/coot/{cootp}/plan2.txt',
		'output/{data}/coot/{cootp}/transported.txt'
	container:
		'docker://koki/ot-experiments:20230925'
	benchmark:
		'benchmarks/{data}_coot_{cootp}.txt'
	log:
		'logs/{data}_coot_{cootp}.log'
	shell:
		'src/coot.sh {input} {output} {wildcards.cootp} >& {log}'

#################################
# Optimal Tensor Transport
#################################
rule ottl1:
	input:
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
	output:
		'output/{data}/ottl1/{ottl1p}/plan1.txt',
		'output/{data}/ottl1/{ottl1p}/plan2.txt',
		'output/{data}/ottl1/{ottl1p}/transported.txt'
	container:
		'docker://koki/ott:20230926'
	benchmark:
		'benchmarks/{data}_ottl1_{ottl1p}.txt'
	log:
		'logs/{data}_ottl1_{ottl1p}.log'
	shell:
		'src/ottl1.sh {input} {output} {wildcards.ottl1p} >& {log}'

rule ottl2:
	input:
		'data/{data}/mat_source.txt',
		'data/{data}/mat_target.txt'
	output:
		'output/{data}/ottl2/{ottl2p}/plan1.txt',
		'output/{data}/ottl2/{ottl2p}/plan2.txt',
		'output/{data}/ottl2/{ottl2p}/transported.txt'
	container:
		'docker://koki/ott:20230926'
	benchmark:
		'benchmarks/{data}_ottl2_{ottl2p}.txt'
	log:
		'logs/{data}_ottl2_{ottl2p}.log'
	shell:
		'src/ottl2.sh {input} {output} {wildcards.ottl2p} >& {log}'

#################################
# Plot
#################################
rule plot_sk:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/sk/{skp}/transported.txt'
	output:
		'plot/{data}/sk_{skp}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_sk_{skp}.txt'
	log:
		'logs/plot_ot_{data}_sk_{skp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_gwrow:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/gwrow/{gwrowp}/transported.txt'
	output:
		'plot/{data}/gwrow_{gwrowp}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_gwrow_{gwrowp}.txt'
	log:
		'logs/plot_ot_{data}_gwrow_{gwrowp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_gwcol:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/gwcol/{gwcolp}/transported.txt'
	output:
		'plot/{data}/gwcol_{gwcolp}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_gwcol_{gwcolp}.txt'
	log:
		'logs/plot_ot_{data}_gwcol_{gwcolp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_coot:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/coot/{cootp}/transported.txt'
	output:
		'plot/{data}/coot_{cootp}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ot_{data}_coot_{cootp}.txt'
	log:
		'logs/plot_ot_{data}_coot_{cootp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_ottl1:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/ottl1/{ottl1p}/transported.txt'
	output:
		'plot/{data}/ottl1_{ottl1p}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ottl1_{data}_ottl1_{ottl1p}.txt'
	log:
		'logs/plot_ottl1_{data}_ottl1_{ottl1p}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_ottl2:
	input:
		'data/{data}/vec_source.txt',
		'output/{data}/ottl2/{ottl2p}/transported.txt'
	output:
		'plot/{data}/ottl2_{ottl2p}.png'
	container:
		'docker://koki/ot-experiments-r:20230926'
	benchmark:
		'benchmarks/plot_ottl2_{data}_ottl2_{ottl2p}.txt'
	log:
		'logs/plot_ottl2_{data}_ottl2_{ottl2p}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'
