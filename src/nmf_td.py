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
infile4 = args[4]
outfile1 = args[5]
outfile2 = args[6]
outfile3 = args[7]
outfile4 = args[8]
outfile5 = args[9]
outfile6 = args[10]
outfile7 = args[11]
outfile8 = args[12]
outfile9 = args[13]
epsilon = float(args[14])

# Loading Data
source_test = np.loadtxt(infile1, delimiter=",")
source_train = np.loadtxt(infile2, delimiter=",")
target_train = np.loadtxt(infile3, delimiter=",")
source_celltype = np.loadtxt(infile4, delimiter=",", skiprows=1)
# max_indices = np.argmax(source_celltype, axis=1)
# tmp = np.zeros_like(source_celltype)
# for row_idx, col_idx in enumerate(max_indices):
#     tmp[row_idx, col_idx] = 1
# source_celltype = tmp

# Log-Transformation
source_test = np.log10(source_test + 1)
source_train = np.log10(source_train + 1)
target_train = np.log10(target_train + 1)

# Numpy => Torch
source_test_torch = torch.from_numpy(source_test)
source_train_torch = torch.from_numpy(source_train)
target_train_torch = torch.from_numpy(target_train)

# Instantiation of NMFLayer
nmf_layer1 = td.NMFLayer(source_train_torch, n_components=4)
nmf_layer2 = td.NMFLayer(target_train_torch, n_components=9)

# Iteration
loss_array = []
epochs = 100
alpha = 0.8
p = np.ones(nmf_layer1.W.shape[1])
q = np.ones(nmf_layer2.W.shape[1])
p = p / np.sum(p)
q = q / np.sum(q)
p = torch.from_numpy(p)
q = torch.from_numpy(q)
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
    C1 = torch.cdist(nmf_layer1.H, nmf_layer1.H, p=2)**2
    C2 = torch.cdist(nmf_layer2.H, nmf_layer2.H, p=2)**2
    gwot_loss = ot.gromov.entropic_gromov_wasserstein2(C1, C2, p=p, q=q, epsilon=epsilon, max_iter=1)
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
            grad_pos1, grad_neg1, grad_pos_w1, grad_neg_w1, grad_pos_h1, grad_neg_h1, nmf_layer1, normW=False, normH=True)
        W2, H2 = td.updateNMF(
            grad_pos2, grad_neg2, grad_pos_w2, grad_neg_w2, grad_pos_h2, grad_neg_h2, nmf_layer2, normW=False, normH=True)
        p = W1.sum(axis=0) * H1.sum(axis=1)
        q = W2.sum(axis=0) * H2.sum(axis=1)
        p = p.to('cpu').detach().numpy().copy()
        q = q.to('cpu').detach().numpy().copy()
        p = torch.from_numpy(p)
        q = torch.from_numpy(q)
        nmf_layer1.W.data = W1
        nmf_layer2.W.data = W2
        nmf_layer1.H.data = H1
        nmf_layer2.H.data = H2

# Transport Plan (After iteration)
C1 = torch.cdist(nmf_layer1.H, nmf_layer1.H, p=2)**2
C2 = torch.cdist(nmf_layer2.H, nmf_layer2.H, p=2)**2
P = ot.gromov.entropic_gromov_wasserstein(C1, C2, epsilon=epsilon).to('cpu').detach().numpy().copy()

# Normalization
if P.max() != 0:
    row_sums = P.sum(axis=1)
    P = P / row_sums[:, np.newaxis]

# Transportation
W1 = nmf_layer1.W.to('cpu').detach().numpy().copy()
W2 = nmf_layer2.W.to('cpu').detach().numpy().copy()
H1 = nmf_layer1.H.to('cpu').detach().numpy().copy()
H2 = nmf_layer2.H.to('cpu').detach().numpy().copy()
t_source_test = np.matmul(np.matmul(np.matmul(source_test.T, W1), P), W2.T).T
t_source_train = np.matmul(np.matmul(np.matmul(source_train.T, W1), P), W2.T).T
t_source_label = np.matmul(np.matmul(np.matmul(source_celltype.T, W1), P), W2.T).T
sum_t_source_label = t_source_label.sum(axis=1, keepdims=True)
t_source_label = t_source_label / sum_t_source_label

# Save
np.savetxt(outfile1, P)
np.savetxt(outfile2, t_source_test)
np.savetxt(outfile3, t_source_train)
np.savetxt(outfile4, t_source_label)
np.savetxt(outfile5, W1)
np.savetxt(outfile6, H1)
np.savetxt(outfile7, W2)
np.savetxt(outfile8, H2)
np.savetxt(outfile9, loss_array)
