# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot
from scipy.spatial import distance

# Arguments
args = sys.argv
infile1 = args[1]
infile2 = args[2]
infile3 = args[3]
outfile1 = args[4]
outfile2 = args[5]
outfile3 = args[6]
epsilon = float(args[7])

# Loading Data
source_test = np.loadtxt(infile1, delimiter=",")
source_train = np.loadtxt(infile2, delimiter=",")
target_train = np.loadtxt(infile3, delimiter=",")

# Gromov-Wasserstein Distance
Cx = distance.cdist(source_train, source_train, metric='euclidean')
Cy = distance.cdist(target_train, target_train, metric='euclidean')
p = ot.unif(source_train.shape[0])
q = ot.unif(target_train.shape[0])
P = ot.gromov.entropic_gromov_wasserstein(Cx, Cy, p, q, 'square_loss', epsilon=epsilon)

if P.max() != 0:
	P /= P.max()

# Transportation
t_source_test = np.matmul(P.T, source_test)
t_source_train = np.matmul(P.T, source_train)

# Save
np.savetxt(outfile1, P)
np.savetxt(outfile2, t_source_test)
np.savetxt(outfile3, t_source_train)
