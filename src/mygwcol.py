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
outfile1 = args[3]
outfile2 = args[4]
epsilon = float(args[5])

# Loading Data
source = np.loadtxt(infile1, delimiter=",")
target = np.loadtxt(infile2, delimiter=",")

# Transpose
source = source.T
target = target.T

# Gromov-Wasserstein Distance
Cx = distance.cdist(source, source, metric='euclidean')
Cy = distance.cdist(target, target, metric='euclidean')
p = ot.unif(source.shape[0])
q = ot.unif(target.shape[0])
P = ot.gromov.entropic_gromov_wasserstein(Cx, Cy, p, q, 'square_loss', epsilon=epsilon)

if P.max() != 0:
	P /= P.max()

# Transportation
t_source = np.matmul(P.T, source)

# Traspose
t_source = t_source.T 

# Save
np.savetxt(outfile1, P)
np.savetxt(outfile2, t_source)
