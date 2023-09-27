# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot

# Arguments
args = sys.argv
infile1 = args[1]
infile2 = args[2]
outfile1 = args[3]
outfile2 = args[4]
reg = float(args[5])

# Loading Data
source = np.loadtxt(infile1, delimiter=",")
target = np.loadtxt(infile2, delimiter=",")

# Reshape
source = source[:,3]
target = target[:,3]

# Euclid Distance
n = source.shape[0]
m = target.shape[0]
D = ot.dist(source.reshape((n, 1)), target.reshape((m, 1)))

# Transport Plan
a = np.ones(n) / n
b = np.ones(m) / m
P = ot.sinkhorn(a, b, D, reg)
P /= P.max()

# Transportation
t_source = np.matmul(source, P)

# Save
np.savetxt(outfile1, P)
np.savetxt(outfile2, t_source)
