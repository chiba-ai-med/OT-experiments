from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("7.1.0")

DATASETS = ['posneg', 'negpos']
GW_PARAMETERS = ['1E+8','1E+9','1E+10','1E+11','1E+12','1E+13','1E+14']
OTT_GW_PARAMETERS = ['1E+9','1E+11','1E+13']
SVD_PARAMETERS = ['1','1E+9','1E+11','1E+13']
NMF_PARAMETERS = ['1','1E+9','1E+11','1E+13']
NMF_TD_PARAMETERS = ['1','1E+9','1E+11','1E+13']

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
			data=DATASETS, nmfp=NMF_PARAMETERS),
		expand('plot/{data}/nmf_td/{nmf_tdp}/finish',
			data=DATASETS, nmf_tdp=NMF_TD_PARAMETERS),
		expand('plot/{data}/wasserstein.png',
			data=DATASETS),
		expand('plot/{data}/ari.png',
			data=DATASETS),
		expand('plot/{data}/svd/{svdp}/umap.png',
			data=DATASETS, svdp=SVD_PARAMETERS),
		expand('plot/{data}/nmf/{nmfp}/umap.png',
			data=DATASETS, nmfp=NMF_PARAMETERS),
		expand('plot/{data}/nmf_td/{nmf_tdp}/umap.png',
			data=DATASETS, nmf_tdp=NMF_TD_PARAMETERS),
		expand('plot/{data}/accuracy.png',
			data=DATASETS)

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
		'data/{data}/target_y_coordinate.txt',
		'data/{data}/source_celltype.txt',
		'data/{data}/target_celltype.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
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
		'data/{data}/target_y_coordinate.txt',
		'data/{data}/source_celltype.txt',
		'data/{data}/target_celltype.txt'
	output:
		'plot/{data}/source_test_data_finish',
		'plot/{data}/target_test_data_finish',
		'plot/{data}/source_train_data_finish',
		'plot/{data}/target_train_data_finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_data_{data}.txt'
	log:
		'logs/plot_data_{data}.log'
	shell:
		'src/plot_smalldata.sh {input} {output} >& {log}'

#################################
# Gromov-Wasserstein
#################################
rule gw:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_celltype.txt'
	output:
		'output/{data}/gw/{gwp}/plan.txt',
		'output/{data}/gw/{gwp}/test_transported.txt',
		'output/{data}/gw/{gwp}/train_transported.txt',
		'output/{data}/gw/{gwp}/celltype_transported.txt'
	container:
		'docker://koki/ot-experiments:20240719'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_gw_{gwp}.txt'
	log:
		'logs/{data}_gw_{gwp}.log'
	shell:
		'src/gw.sh {input} {output} {wildcards.gwp} >& {log}'

rule accuracy_gw:
	input:
		'output/{data}/gw/{gwp}/celltype_transported.txt',
		'data/{data}/target_celltype.txt'
	output:
		'output/{data}/gw/{gwp}/accuracy.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_accuracy_gw_{gwp}.txt'
	log:
		'logs/{data}_accuracy_gw_{gwp}.log'
	shell:
		'src/accuracy.sh {input} {output} >& {log}'

#################################
# Optimal Tensor Transport
#################################
rule ott_gw:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_celltype.txt'
	output:
		'output/{data}/ott_gw/{ott_gwp}/plan.txt',
		'output/{data}/ott_gw/{ott_gwp}/test_transported.txt',
		'output/{data}/ott_gw/{ott_gwp}/train_transported.txt',
		'output/{data}/ott_gw/{ott_gwp}/celltype_transported.txt'
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

rule accuracy_ott_gw:
	input:
		'output/{data}/ott_gw/{ott_gwp}/celltype_transported.txt',
		'data/{data}/target_celltype.txt'
	output:
		'output/{data}/ott_gw/{ott_gwp}/accuracy.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_accuracy_ott_gw_{ott_gwp}.txt'
	log:
		'logs/{data}_accuracy_ott_gw_{ott_gwp}.log'
	shell:
		'src/accuracy.sh {input} {output} >& {log}'

#################################
# SVD → GW
#################################
rule svd:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_celltype.txt'
	output:
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/test_transported.txt',
		'output/{data}/svd/{svdp}/train_transported.txt',
		'output/{data}/svd/{svdp}/celltype_transported.txt',
		'output/{data}/svd/{svdp}/u_s.txt',
		'output/{data}/svd/{svdp}/v_s.txt',
		'output/{data}/svd/{svdp}/u_t.txt',
		'output/{data}/svd/{svdp}/v_t.txt'
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

rule wasserstein_svd:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/v_s.txt',
		'output/{data}/svd/{svdp}/train_transported.txt'
	output:
		'output/{data}/svd/{svdp}/wasserstein1.txt',
		'output/{data}/svd/{svdp}/wasserstein2.txt',
		'output/{data}/svd/{svdp}/wasserstein3.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_wasserstein_svd_{svdp}.txt'
	log:
		'logs/{data}_wasserstein_svd_{svdp}.log'
	shell:
		'src/wasserstein.sh {input} {output} >& {log}'

rule accuracy_svd:
	input:
		'output/{data}/svd/{svdp}/celltype_transported.txt',
		'data/{data}/target_celltype.txt'
	output:
		'output/{data}/svd/{svdp}/accuracy.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_accuracy_svd_{svdp}.txt'
	log:
		'logs/{data}_accuracy_svd_{svdp}.log'
	shell:
		'src/accuracy.sh {input} {output} >& {log}'

rule clustering_umap_svd:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/v_s.txt',
		'output/{data}/svd/{svdp}/train_transported.txt'
	output:
		'output/{data}/svd/{svdp}/cluster1.txt',
		'output/{data}/svd/{svdp}/cluster2.txt',
		'output/{data}/svd/{svdp}/cluster3.txt',
		'output/{data}/svd/{svdp}/cluster4.txt',
		'output/{data}/svd/{svdp}/ari1.txt',
		'output/{data}/svd/{svdp}/ari2.txt',
		'output/{data}/svd/{svdp}/ari3.txt',
		'output/{data}/svd/{svdp}/umap1.txt',
		'output/{data}/svd/{svdp}/umap2.txt',
		'output/{data}/svd/{svdp}/umap3.txt',
		'output/{data}/svd/{svdp}/umap4.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_clustering_svd_{svdp}.txt'
	log:
		'logs/{data}_clustering_svd_{svdp}.log'
	shell:
		'src/clustering_umap.sh {input} {output} >& {log}'

#################################
# NMF → GW
#################################
rule nmf:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_celltype.txt'
	output:
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/test_transported.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt',
		'output/{data}/nmf/{nmfp}/celltype_transported.txt',
		'output/{data}/nmf/{nmfp}/u_s.txt',
		'output/{data}/nmf/{nmfp}/v_s.txt',
		'output/{data}/nmf/{nmfp}/u_t.txt',
		'output/{data}/nmf/{nmfp}/v_t.txt',
		'output/{data}/nmf/{nmfp}/rec_error.txt'
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

rule wasserstein_nmf:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/v_s.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt'
	output:
		'output/{data}/nmf/{nmfp}/wasserstein1.txt',
		'output/{data}/nmf/{nmfp}/wasserstein2.txt',
		'output/{data}/nmf/{nmfp}/wasserstein3.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_wasserstein_nmf_{nmfp}.txt'
	log:
		'logs/{data}_wasserstein_nmf_{nmfp}.log'
	shell:
		'src/wasserstein.sh {input} {output} >& {log}'

rule accuracy_nmf:
	input:
		'output/{data}/nmf/{nmfp}/celltype_transported.txt',
		'data/{data}/target_celltype.txt'
	output:
		'output/{data}/nmf/{nmfp}/accuracy.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_accuracy_nmf_{nmfp}.txt'
	log:
		'logs/{data}_accuracy_nmf_{nmfp}.log'
	shell:
		'src/accuracy.sh {input} {output} >& {log}'

rule clustering_umap_nmf:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/v_s.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt'
	output:
		'output/{data}/nmf/{nmfp}/cluster1.txt',
		'output/{data}/nmf/{nmfp}/cluster2.txt',
		'output/{data}/nmf/{nmfp}/cluster3.txt',
		'output/{data}/nmf/{nmfp}/cluster4.txt',
		'output/{data}/nmf/{nmfp}/ari1.txt',
		'output/{data}/nmf/{nmfp}/ari2.txt',
		'output/{data}/nmf/{nmfp}/ari3.txt',
		'output/{data}/nmf/{nmfp}/umap1.txt',
		'output/{data}/nmf/{nmfp}/umap2.txt',
		'output/{data}/nmf/{nmfp}/umap3.txt',
		'output/{data}/nmf/{nmfp}/umap4.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_clustering_nmf_{nmfp}.txt'
	log:
		'logs/{data}_clustering_nmf_{nmfp}.log'
	shell:
		'src/clustering_umap.sh {input} {output} >& {log}'

#################################
# NMF → GW (PyTorchDecomp)
#################################
rule nmf_td:
	input:
		'data/{data}/source_test_data.txt',
		'data/{data}/source_train_data.txt',
		'data/{data}/target_train_data.txt',
		'data/{data}/source_celltype.txt'
	output:
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/test_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/celltype_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/u_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/u_t.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_t.txt',
		'output/{data}/nmf_td/{nmf_tdp}/rec_error.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_nmf_td_{nmf_tdp}.log'
	shell:
		'src/nmf_td.sh {input} {output} {wildcards.nmf_tdp} >& {log}'

rule wasserstein_nmf_td:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt'
	output:
		'output/{data}/nmf_td/{nmf_tdp}/wasserstein1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/wasserstein2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/wasserstein3.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_wasserstein_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_wasserstein_nmf_td_{nmf_tdp}.log'
	shell:
		'src/wasserstein.sh {input} {output} >& {log}'

rule accuracy_nmf_td:
	input:
		'output/{data}/nmf_td/{nmf_tdp}/celltype_transported.txt',
		'data/{data}/target_celltype.txt'
	output:
		'output/{data}/nmf_td/{nmf_tdp}/accuracy.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_accuracy_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_accuracy_nmf_td_{nmf_tdp}.log'
	shell:
		'src/accuracy.sh {input} {output} >& {log}'

rule clustering_umap_nmf_td:
	input:
		'data/{data}/source_train_data.txt',
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt'
	output:
		'output/{data}/nmf_td/{nmf_tdp}/cluster1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster3.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster4.txt',
		'output/{data}/nmf_td/{nmf_tdp}/ari1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/ari2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/ari3.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap3.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap4.txt'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_clustering_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_clustering_nmf_td_{nmf_tdp}.log'
	shell:
		'src/clustering_umap.sh {input} {output} >& {log}'

#################################
# Plot
#################################
rule plot_gw:
	input:
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt',
		'output/{data}/gw/{gwp}/plan.txt',
		'output/{data}/gw/{gwp}/test_transported.txt',
		'output/{data}/gw/{gwp}/train_transported.txt'
	output:
		'plot/{data}/gw/{gwp}/finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_ot_{data}_gw_{gwp}.txt'
	log:
		'logs/plot_ot_{data}_gw_{gwp}.log'
	shell:
		'src/plot_ot.sh {input} {output} >& {log}'

rule plot_ott_gw:
	input:
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt',
		'output/{data}/ott_gw/{ott_gwp}/plan.txt',
		'output/{data}/ott_gw/{ott_gwp}/test_transported.txt',
		'output/{data}/ott_gw/{ott_gwp}/train_transported.txt'
	output:
		'plot/{data}/ott_gw/{ott_gwp}/finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
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
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt',
		'output/{data}/svd/{svdp}/plan.txt',
		'output/{data}/svd/{svdp}/test_transported.txt',
		'output/{data}/svd/{svdp}/train_transported.txt',
		'output/{data}/svd/{svdp}/u_s.txt',
		'output/{data}/svd/{svdp}/v_s.txt',
		'output/{data}/svd/{svdp}/u_t.txt',
		'output/{data}/svd/{svdp}/v_t.txt'
	output:
		'plot/{data}/svd/{svdp}/finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_ot_{data}_svd_{svdp}.txt'
	log:
		'logs/plot_ot_{data}_svd_{svdp}.log'
	shell:
		'src/plot_svd.sh {input} {output} >& {log}'

rule plot_nmf:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt',
		'output/{data}/nmf/{nmfp}/plan.txt',
		'output/{data}/nmf/{nmfp}/test_transported.txt',
		'output/{data}/nmf/{nmfp}/train_transported.txt',
		'output/{data}/nmf/{nmfp}/u_s.txt',
		'output/{data}/nmf/{nmfp}/v_s.txt',
		'output/{data}/nmf/{nmfp}/u_t.txt',
		'output/{data}/nmf/{nmfp}/v_t.txt',
		'output/{data}/nmf/{nmfp}/rec_error.txt'
	output:
		'plot/{data}/nmf/{nmfp}/finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_ot_{data}_nmf_{nmfp}.txt'
	log:
		'logs/plot_ot_{data}_nmf_{nmfp}.log'
	shell:
		'src/plot_ot_factor.sh {input} {output} >& {log}'

rule plot_nmf_td:
	input:
		'data/{data}/source_x_coordinate.txt',
		'data/{data}/source_y_coordinate.txt',
		'data/{data}/target_x_coordinate.txt',
		'data/{data}/target_y_coordinate.txt',
		'output/{data}/nmf_td/{nmf_tdp}/plan.txt',
		'output/{data}/nmf_td/{nmf_tdp}/test_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/train_transported.txt',
		'output/{data}/nmf_td/{nmf_tdp}/u_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_s.txt',
		'output/{data}/nmf_td/{nmf_tdp}/u_t.txt',
		'output/{data}/nmf_td/{nmf_tdp}/v_t.txt',
		'output/{data}/nmf_td/{nmf_tdp}/rec_error.txt'
	output:
		'plot/{data}/nmf_td/{nmf_tdp}/finish'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_ot_{data}_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/plot_ot_{data}_nmf_td_{nmf_tdp}.log'
	shell:
		'src/plot_ot_factor.sh {input} {output} >& {log}'

# Plot Wasserstein
def aggr_wasserstein_svd1(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/wasserstein1.txt')
	return(out)

def aggr_wasserstein_svd2(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/wasserstein2.txt')
	return(out)

def aggr_wasserstein_svd3(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/wasserstein3.txt')
	return(out)

def aggr_wasserstein_nmf1(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/wasserstein1.txt')
	return(out)

def aggr_wasserstein_nmf2(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/wasserstein2.txt')
	return(out)

def aggr_wasserstein_nmf3(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/wasserstein3.txt')
	return(out)

def aggr_wasserstein_nmf_td1(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/wasserstein1.txt')
	return(out)

def aggr_wasserstein_nmf_td2(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/wasserstein2.txt')
	return(out)

def aggr_wasserstein_nmf_td3(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/wasserstein3.txt')
	return(out)

rule aggregate_wasserstein_svd:
	input:
		aggr_wasserstein_svd1,
		aggr_wasserstein_svd2,
		aggr_wasserstein_svd3
	output:
		'output/{data}/svd/wasserstein.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_wasserstein_svd.txt'
	log:
		'logs/{data}_aggregate_wasserstein_svd.log'
	shell:
		'src/aggregate_wasserstein.sh {input} {output} >& {log}'

rule aggregate_wasserstein_nmf:
	input:
		aggr_wasserstein_nmf1,
		aggr_wasserstein_nmf2,
		aggr_wasserstein_nmf3
	output:
		'output/{data}/nmf/wasserstein.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_wasserstein_nmf.txt'
	log:
		'logs/{data}_aggregate_wasserstein_nmf.log'
	shell:
		'src/aggregate_wasserstein.sh {input} {output} >& {log}'

rule aggregate_wasserstein_nmf_td:
	input:
		aggr_wasserstein_nmf_td1,
		aggr_wasserstein_nmf_td2,
		aggr_wasserstein_nmf_td3
	output:
		'output/{data}/nmf_td/wasserstein.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_wasserstein_nmf_td.txt'
	log:
		'logs/{data}_aggregate_wasserstein_nmf_td.log'
	shell:
		'src/aggregate_wasserstein.sh {input} {output} >& {log}'

rule plot_wasserstein:
	input:
		'output/{data}/svd/wasserstein.txt',
		'output/{data}/nmf/wasserstein.txt',
		'output/{data}/nmf_td/wasserstein.txt'
	output:
		'plot/{data}/wasserstein.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_wasserstein_{data}.txt'
	log:
		'logs/plot_wasserstein_{data}.log'
	shell:
		'src/plot_wasserstein.sh {input} {output} >& {log}'

# Plot Adjusted Rand Index
def aggr_ari_svd1(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/ari1.txt')
	return(out)

def aggr_ari_svd2(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/ari2.txt')
	return(out)

def aggr_ari_svd3(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/ari3.txt')
	return(out)

def aggr_ari_nmf1(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/ari1.txt')
	return(out)

def aggr_ari_nmf2(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/ari2.txt')
	return(out)

def aggr_ari_nmf3(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/ari3.txt')
	return(out)

def aggr_ari_nmf_td1(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/ari1.txt')
	return(out)

def aggr_ari_nmf_td2(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/ari2.txt')
	return(out)

def aggr_ari_nmf_td3(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/ari3.txt')
	return(out)

rule aggregate_ari_svd:
	input:
		aggr_ari_svd1,
		aggr_ari_svd2,
		aggr_ari_svd3
	output:
		'output/{data}/svd/ari.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_ari_svd.txt'
	log:
		'logs/{data}_aggregate_ari_svd.log'
	shell:
		'src/aggregate_ari.sh {input} {output} >& {log}'

rule aggregate_ari_nmf:
	input:
		aggr_ari_nmf1,
		aggr_ari_nmf2,
		aggr_ari_nmf3
	output:
		'output/{data}/nmf/ari.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_ari_nmf.txt'
	log:
		'logs/{data}_aggregate_ari_nmf.log'
	shell:
		'src/aggregate_ari.sh {input} {output} >& {log}'

rule aggregate_ari_nmf_td:
	input:
		aggr_ari_nmf_td1,
		aggr_ari_nmf_td2,
		aggr_ari_nmf_td3
	output:
		'output/{data}/nmf_td/ari.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_ari_nmf_td.txt'
	log:
		'logs/{data}_aggregate_ari_nmf_td.log'
	shell:
		'src/aggregate_ari.sh {input} {output} >& {log}'

rule plot_ari:
	input:
		'output/{data}/svd/ari.txt',
		'output/{data}/nmf/ari.txt',
		'output/{data}/nmf_td/ari.txt'
	output:
		'plot/{data}/ari.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_ari_{data}.txt'
	log:
		'logs/plot_ari_{data}.log'
	shell:
		'src/plot_ari.sh {input} {output} >& {log}'

# Plot Accuracy
def aggr_accuracy_gw(wld):
	data = wld[0]
	out = []
	for j in range(len(GW_PARAMETERS)):
		out.append('output/{data}/gw/' + GW_PARAMETERS[j] + '/accuracy.txt')
	return(out)

def aggr_accuracy_ott_gw(wld):
	data = wld[0]
	out = []
	for j in range(len(OTT_GW_PARAMETERS)):
		out.append('output/{data}/ott_gw/' + OTT_GW_PARAMETERS[j] + '/accuracy.txt')
	return(out)

def aggr_accuracy_svd(wld):
	data = wld[0]
	out = []
	for j in range(len(SVD_PARAMETERS)):
		out.append('output/{data}/svd/' + SVD_PARAMETERS[j] + '/accuracy.txt')
	return(out)

def aggr_accuracy_nmf(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_PARAMETERS)):
		out.append('output/{data}/nmf/' + NMF_PARAMETERS[j] + '/accuracy.txt')
	return(out)

def aggr_accuracy_nmf_td(wld):
	data = wld[0]
	out = []
	for j in range(len(NMF_TD_PARAMETERS)):
		out.append('output/{data}/nmf_td/' + NMF_TD_PARAMETERS[j] + '/accuracy.txt')
	return(out)

rule aggregate_accuracy_gw:
	input:
		aggr_accuracy_gw,
	output:
		'output/{data}/gw/accuracy.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_accuracy_gw.txt'
	log:
		'logs/{data}_aggregate_accuracy_gw.log'
	shell:
		'src/aggregate_accuracy.sh {input} {output} >& {log}'

rule aggregate_accuracy_ott_gw:
	input:
		aggr_accuracy_ott_gw,
	output:
		'output/{data}/ott_gw/accuracy.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_accuracy_ott_gw.txt'
	log:
		'logs/{data}_aggregate_accuracy_ott_gw.log'
	shell:
		'src/aggregate_accuracy.sh {input} {output} >& {log}'

rule aggregate_accuracy_svd:
	input:
		aggr_accuracy_svd,
	output:
		'output/{data}/svd/accuracy.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_accuracy_svd.txt'
	log:
		'logs/{data}_aggregate_accuracy_svd.log'
	shell:
		'src/aggregate_accuracy.sh {input} {output} >& {log}'

rule aggregate_accuracy_nmf:
	input:
		aggr_accuracy_nmf
	output:
		'output/{data}/nmf/accuracy.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_accuracy_nmf.txt'
	log:
		'logs/{data}_aggregate_accuracy_nmf.log'
	shell:
		'src/aggregate_accuracy.sh {input} {output} >& {log}'

rule aggregate_accuracy_nmf_td:
	input:
		aggr_accuracy_nmf_td
	output:
		'output/{data}/nmf_td/accuracy.txt'
	container:
		'docker://koki/ot-experiments-td:20240620'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_aggregate_accuracy_nmf_td.txt'
	log:
		'logs/{data}_aggregate_accuracy_nmf_td.log'
	shell:
		'src/aggregate_accuracy.sh {input} {output} >& {log}'

rule plot_accuracy:
	input:
		'output/{data}/gw/accuracy.txt',
		'output/{data}/ott_gw/accuracy.txt',
		'output/{data}/svd/accuracy.txt',
		'output/{data}/nmf/accuracy.txt',
		'output/{data}/nmf_td/accuracy.txt'
	output:
		'plot/{data}/accuracy.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	benchmark:
		'benchmarks/plot_accuracy_{data}.txt'
	log:
		'logs/plot_accuracy_{data}.log'
	shell:
		'src/plot_accuracy_small.sh {input} {output} >& {log}'

# Plot Louvain Clustering/UMAP
rule plot_clustering_umap_svd:
	input:
		'output/{data}/svd/{svdp}/cluster1.txt',
		'output/{data}/svd/{svdp}/cluster2.txt',
		'output/{data}/svd/{svdp}/cluster3.txt',
		'output/{data}/svd/{svdp}/cluster4.txt',
		'output/{data}/svd/{svdp}/umap1.txt',
		'output/{data}/svd/{svdp}/umap2.txt',
		'output/{data}/svd/{svdp}/umap3.txt',
		'output/{data}/svd/{svdp}/umap4.txt'
	output:
		'plot/{data}/svd/{svdp}/umap.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_plot_clustering_umap_svd_{svdp}.txt'
	log:
		'logs/{data}_plot_clustering_umap_svd_{svdp}.log'
	shell:
		'src/plot_clustering_umap.sh {input} {output} >& {log}'

rule plot_clustering_umap_nmf:
	input:
		'output/{data}/nmf/{nmfp}/cluster1.txt',
		'output/{data}/nmf/{nmfp}/cluster2.txt',
		'output/{data}/nmf/{nmfp}/cluster3.txt',
		'output/{data}/nmf/{nmfp}/cluster4.txt',
		'output/{data}/nmf/{nmfp}/umap1.txt',
		'output/{data}/nmf/{nmfp}/umap2.txt',
		'output/{data}/nmf/{nmfp}/umap3.txt',
		'output/{data}/nmf/{nmfp}/umap4.txt'
	output:
		'plot/{data}/nmf/{nmfp}/umap.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_plot_clustering_umap_nmf_{nmfp}.txt'
	log:
		'logs/{data}_plot_clustering_umap_nmf_{nmfp}.log'
	shell:
		'src/plot_clustering_umap.sh {input} {output} >& {log}'

rule plot_clustering_umap_nmf_td:
	input:
		'output/{data}/nmf_td/{nmf_tdp}/cluster1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster3.txt',
		'output/{data}/nmf_td/{nmf_tdp}/cluster4.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap1.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap2.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap3.txt',
		'output/{data}/nmf_td/{nmf_tdp}/umap4.txt'
	output:
		'plot/{data}/nmf_td/{nmf_tdp}/umap.png'
	container:
		'docker://koki/ot-experiments-r:20240627'
	resources:
		mem_mb=10000
	benchmark:
		'benchmarks/{data}_plot_clustering_umap_nmf_td_{nmf_tdp}.txt'
	log:
		'logs/{data}_plot_clustering_umap_nmf_td_{nmf_tdp}.log'
	shell:
		'src/plot_clustering_umap.sh {input} {output} >& {log}'
