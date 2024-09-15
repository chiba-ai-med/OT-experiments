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
infile4 = args[4]
outfile1 = args[5]
outfile2 = args[6]
outfile3 = args[7]

# Loading Data
source_train = np.loadtxt(infile1, delimiter=",")
P = np.loadtxt(infile2)
v_s = np.loadtxt(infile3)
rec_t_v_s = np.loadtxt(infile4)

# Transport
t_v_s = np.matmul(P.T, v_s)

# Sinkhorn Distance
C1 = distance.cdist(source_train, v_s, metric='euclidean')
C2 = distance.cdist(v_s, t_v_s, metric='euclidean')
C3 = distance.cdist(t_v_s, rec_t_v_s, metric='euclidean')

p1 = ot.unif(source_train.shape[0])
q1 = ot.unif(v_s.shape[0])
dist1 = ot.sinkhorn2(p1, q1, C1, reg=10)

p2 = ot.unif(v_s.shape[0])
q2 = ot.unif(t_v_s.shape[0])
dist2 = ot.sinkhorn2(p2, q2, C2, reg=10)

p3 = ot.unif(t_v_s.shape[0])
q3 = ot.unif(rec_t_v_s.shape[0])
dist3 = ot.sinkhorn2(p3, q3, C3, reg=10)

# Save
np.savetxt(outfile1, [dist1])
np.savetxt(outfile2, [dist2])
np.savetxt(outfile3, [dist3])
