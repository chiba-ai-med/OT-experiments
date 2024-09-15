# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot
from scipy.spatial import distance
from sklearn.cluster import KMeans
import pickle

# Arguments
args = sys.argv
infile1 = args[1]
infile2 = args[2]
infile3 = args[3]
infile4 = args[4]
outfile1 = args[5]
outfile2 = args[6]
outfile3 = args[7]
outfile4 = args[8]
epsilon = float(args[9])

# Loading Data
source_test = np.loadtxt(infile1, delimiter=",")
source_train = np.loadtxt(infile2, delimiter=",")
target_train = np.loadtxt(infile3, delimiter=",")
source_celltype = np.loadtxt(infile4, delimiter=",", skiprows=1)

# Log-Transformation
source_test = np.log10(source_test + 1)
source_train = np.log10(source_train + 1)
target_train = np.log10(target_train + 1)

# Distance
C1 = distance.cdist(source_train, source_train)
C2 = distance.cdist(target_train, target_train)

# Merginal Distribution
h1 = np.ones(C1.shape[0]) / C1.shape[0]
h2 = np.ones(C2.shape[0]) / C2.shape[0]

# Clustering（重いステップ1、C1/C2に対しては計算できなかった）
part1 = KMeans(n_clusters=1000, random_state=0, n_init="auto").fit(source_train).labels_
part2 = KMeans(n_clusters=1000, random_state=0, n_init="auto").fit(target_train).labels_

# Cluster Center
rep_indices1 = ot.gromov.get_graph_representants(C1, part1, rep_method='pagerank')
rep_indices2 = ot.gromov.get_graph_representants(C2, part2, rep_method='pagerank')

# Formatting
CR1, list_R1, list_h1 = ot.gromov.format_partitioned_graph(
    C1, h1, part1, rep_indices1, F=None, M=None, alpha=1.)
CR2, list_R2, list_h2 = ot.gromov.format_partitioned_graph(
    C2, h2, part2, rep_indices2, F=None, M=None, alpha=1.)

# Partitioned quantized gromov-wasserstein solver（重いステップ2, build_OT=Falseなら動く）
T_global, Ts_local, _, log = ot.gromov.quantized_fused_gromov_wasserstein_partitioned(
    CR1, CR2, list_R1, list_R2, list_h1, list_h2, MR=None,
    alpha=1., build_OT=False, log=True, reg=epsilon, verbose=True)

# Transportation
t_source_train = np.zeros((target_train.shape[0], source_train.shape[1]))
t_source_test = np.zeros((target_train.shape[0], 1))
t_source_label = np.zeros((target_train.shape[0], source_celltype.shape[1]))

for i in range(1000):
    list_Ti = []
    for j in range(1000):
        if T_global[i, j] == 0.:
            T_local = np.zeros((list_R1[i].shape[0], list_R2[j].shape[0]))
        else:
            T_local = T_global[i, j] * Ts_local[(i, j)]
        list_Ti.append(T_local)
    Ti = np.concatenate(list_Ti, axis=1)
    T_rows.append(Ti)
    # Normalization
    if Ti.max() != 0:
        row_sums = Ti.sum(axis=1)
        Ti = Ti / row_sums[:, np.newaxis]
    # Update
    position = np.where(part1 == i)[0]
    t_source_train += Ti.T @ source_train[position, ]
    t_source_test += Ti.T @ source_test[position].reshape(-1, 1)
    t_source_label += Ti.T @ source_celltype[position, ]

sum_t_source_label = t_source_label.sum(axis=1, keepdims=True)
t_source_label = t_source_label / sum_t_source_label

# Save
with open(outfile1, 'wb') as f:
    pickle.dump(T_global, f)
    pickle.dump(Ts_local, f)
    pickle.dump(log, f)

np.savetxt(outfile2, t_source_test)
np.savetxt(outfile3, t_source_train)
np.savetxt(outfile4, t_source_label)

# Ref
# https://pythonot.github.io/auto_examples/gromov/plot_quantized_gromov_wasserstein.html
# https://pythonot.github.io/gen_modules/ot.gromov.html#ot.gromov.quantized_fused_gromov_wasserstein
# https://github.com/PythonOT/POT/blob/36c9252b09138f61bac07eb857e9121de1aaeaf6/ot/gromov/_quantized.py#L206-L219