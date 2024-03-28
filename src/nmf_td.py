# -*- coding: utf-8 -*-

# Package Loading
import sys
import numpy as np
import ot
from scipy.spatial import distance
import torch
import torchdecomp as td

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

# Numpy => Torch
source_test_torch = torch.from_numpy(source_test)
source_train_torch = torch.from_numpy(source_train)
target_train_torch = torch.from_numpy(target_train)

# Instantiation of NMFLayer
nmf_layer1 = td.NMFLayer(source_train_torch, 10)
nmf_layer2 = td.NMFLayer(target_train_torch, 10)

# Iteration
loss_array = []
epochs = 100
alpha = 0.5
for epoch in range(epochs):
    # Initialize Gradient
    nmf_layer1.zero_grad()
    nmf_layer2.zero_grad()
    # Forward
    nmf_loss1, WH1, pos1, neg1, pos_w1, neg_w1, pos_h1, neg_h1 = nmf_layer1(
        source_train_torch)
    nmf_loss2, WH2, pos2, neg2, pos_w2, neg_w2, pos_h2, neg_h2 = nmf_layer2(
        target_train_torch)
    # GW-OT
    C1 = torch.cdist(nmf_layer1.H.t(), nmf_layer1.H.t(), p=2)**2
    C2 = torch.cdist(nmf_layer2.H.t(), nmf_layer2.H.t(), p=2)**2
    gwot_loss = ot.gromov.entropic_gromov_wasserstein2(C1, C2, epsilon=epsilon)
    # Total Loss
    loss = (1 - alpha)*nmf_loss1 + (1 - alpha)*nmf_loss2 + alpha*gwot_loss
    loss_array.append(loss.to('cpu').detach().numpy().copy())
    # Backpropagation
    loss.backward(retain_graph=True)
    # Multiplicative Update (MU) rule
    with torch.no_grad():
        # Gradients
        grad_pos1, grad_neg1, grad_pos_w1, grad_neg_w1, grad_pos_h1, grad_neg_h1 = td.gradNMF(
            WH1, pos1, neg1, pos_w1, neg_w1, pos_h1, neg_h1, nmf_layer1)
        grad_pos2, grad_neg2, grad_pos_w2, grad_neg_w2, grad_pos_h2, grad_neg_h2 = td.gradNMF(
            WH2, pos2, neg2, pos_w2, neg_w2, pos_h2, neg_h2, nmf_layer2)
        # Update
        W1, H1 = td.updateNMF(
            grad_pos1, grad_neg1, grad_pos_w1, grad_neg_w1, grad_pos_h1, grad_neg_h1, nmf_layer1)
        W2, H2 = td.updateNMF(
            grad_pos2, grad_neg2, grad_pos_w2, grad_neg_w2, grad_pos_h2, grad_neg_h2, nmf_layer2)
        nmf_layer1.W.data = W1
        nmf_layer2.W.data = W2
        nmf_layer1.H.data = H1
        nmf_layer2.H.data = H2

# Transport Plan (After iteration)
C1 = torch.cdist(nmf_layer1.H.t(), nmf_layer1.H.t(), p=2)**2
C2 = torch.cdist(nmf_layer2.H.t(), nmf_layer2.H.t(), p=2)**2
P = ot.gromov.entropic_gromov_wasserstein(C1, C2, epsilon=epsilon).to('cpu').detach().numpy().copy()

# Normalization
if P.max() != 0:
    P /= P.max()

# Transportation
W1 = nmf_layer1.W.to('cpu').detach().numpy().copy()
W2 = nmf_layer2.W.to('cpu').detach().numpy().copy()
t_source_test = np.matmul(np.matmul(source_test, W1), W2.T)
t_source_train = np.matmul(source_train, P)

# Save
np.savetxt(outfile1, P)
np.savetxt(outfile2, t_source_test)
np.savetxt(outfile3, t_source_train)
