# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot
from scipy.spatial import distance
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

# Compute the low rank sqeuclidean cost decompositions
A1, A2 = ot.lowrank.compute_lr_sqeuclidean_matrix(source_train, source_train, rescale_cost=False)
B1, B2 = ot.lowrank.compute_lr_sqeuclidean_matrix(target_train, target_train, rescale_cost=False)

# Low-rank GW
Q, R, g, log = ot.lowrank_gromov_wasserstein_samples(
    source_train, target_train,
    reg=epsilon, rank=10, rescale_cost=False, cost_factorized_Xs=(A1, A2),
    cost_factorized_Xt=(B1, B2), seed_init=49, numItermax=100, log=True, stopThr=1e-6)

# Transportation
t_source_train = R @ np.diag(1/g) @ (Q.T @ source_train)
t_source_test = R @ np.diag(1/g) @ (Q.T @ source_test)
t_source_label = R @ np.diag(1/g) @ (Q.T @ source_celltype)
sum_t_source_label = t_source_label.sum(axis=1, keepdims=True)
t_source_label = t_source_label / sum_t_source_label

# Save
with open(outfile1, 'wb') as f:
    pickle.dump(Q, f)
    pickle.dump(g, f)
    pickle.dump(R, f)

np.savetxt(outfile2, t_source_test)
np.savetxt(outfile3, t_source_train)
np.savetxt(outfile4, t_source_label)
