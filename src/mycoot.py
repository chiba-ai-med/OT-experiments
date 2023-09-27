# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot
from ot.coot import co_optimal_transport as coot

# Arguments
args = sys.argv
infile1 = args[1]
infile2 = args[2]
outfile1 = args[3]
outfile2 = args[4]
outfile3 = args[5]
epsilon = float(args[6])

# Loading Data
source = np.loadtxt(infile1, delimiter=",")
target = np.loadtxt(infile2, delimiter=",")

# Transport Plan
P1, P2 = coot(source, target, epsilon=epsilon, nits_bcd=10000)

if P1.max() != 0:
	P1 /= P1.max()

if P2.max() != 0:
	P2 /= P2.max()

# Transportation
t_source = np.matmul(P1.T, np.matmul(source, P2))

# Save
np.savetxt(outfile1, P1)
np.savetxt(outfile2, P2)
np.savetxt(outfile3, t_source)
