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
infile3 = args[3]
outfile1 = args[4]
outfile2 = args[5]
outfile3 = args[6]
outfile4 = args[7]
epsilon = float(args[8])

# Loading Data
source_test = np.loadtxt(infile1, delimiter=",")
source_train = np.loadtxt(infile2, delimiter=",")
target_train = np.loadtxt(infile3, delimiter=",")

# Transport Plan
P1, P2 = coot(source_train, target_train, epsilon=epsilon, nits_bcd=10000)

if P1.max() != 0:
	P1 /= P1.max()

if P2.max() != 0:
	P2 /= P2.max()

# Transportation
t_source_test = np.matmul(P1.T, np.matmul(source_test, P2))
t_source_train = np.matmul(P1.T, np.matmul(source_train, P2))

# Save
np.savetxt(outfile1, P1)
np.savetxt(outfile2, P2)
np.savetxt(outfile3, t_source_test)
np.savetxt(outfile4, t_source_train)
