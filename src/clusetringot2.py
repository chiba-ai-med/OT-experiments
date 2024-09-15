import numpy as np
import ot
from scipy.spatial import distance
from sklearn.cluster import KMeans

# Loading
X = np.loadtxt("data/large_posneg/source_train_data.txt", delimiter=",")
Y = np.loadtxt("data/large_posneg/target_train_data.txt", delimiter=",")

coordinateX_x = np.loadtxt(
    "data/large_posneg/source_x_coordinate.txt", delimiter=",")
coordinateX_y = np.loadtxt(
    "data/large_posneg/source_y_coordinate.txt", delimiter=",")
coordinateX = np.vstack((coordinateX_x, coordinateX_y)).T

coordinateY_x = np.loadtxt(
    "data/large_posneg/target_x_coordinate.txt", delimiter=",")
coordinateY_y = np.loadtxt(
    "data/large_posneg/target_y_coordinate.txt", delimiter=",")
coordinateY = np.vstack((coordinateY_x, coordinateY_y)).T

# Log-Transformation
X = np.log10(X + 1)
Y = np.log10(Y + 1)

# クラスタリング
n_clustersX = 10
n_clustersY = 15
kmeansX = KMeans(n_clusters=n_clustersX, random_state=0, n_init="auto").fit(X)
kmeansY = KMeans(n_clusters=n_clustersY, random_state=0, n_init="auto").fit(Y)

# クラスタラベル
clusterX = kmeansX.labels_
clusterY = kmeansY.labels_

# クラスタ中心
centerX_exp = kmeansX.cluster_centers_
centerY_exp = kmeansY.cluster_centers_

# クラスタ中心間距離行列（発現量）
C1_1 = distance.cdist(centerX_exp, centerX_exp)
C2_1 = distance.cdist(centerY_exp, centerY_exp)

# ダミー変数行列
dummyX = np.zeros((X.shape[0], n_clustersX))
dummyY = np.zeros((Y.shape[0], n_clustersY))
dummyX[np.arange(X.shape[0]), clusterX] = 1
dummyY[np.arange(Y.shape[0]), clusterY] = 1
norm_dummyX = dummyX / dummyX.sum(axis=0)
norm_dummyY = dummyY / dummyY.sum(axis=0)

# クラスタ中心間距離行列（座標）
centerX_coordinate = norm_dummyX.T @ coordinateX
centerY_coordinate = norm_dummyY.T @ coordinateY
C1_2 = distance.cdist(centerX_coordinate, centerX_coordinate)
C2_2 = distance.cdist(centerY_coordinate, centerY_coordinate)

# クラスタ中心間距離行列（マージ）
alpha = 0.5
C1 = alpha * C1_1 + (1 - alpha) * C1_2
C2 = alpha * C2_1 + (1 - alpha) * C2_2

# GW-OT
P = ot.gromov.entropic_gromov_wasserstein(C1, C2, epsilon=10^4, max_iter=100, loss_fun='square_loss', verbose=True, log=True)

# Normalization
if P.max() != 0:
    row_sums = P.sum(axis=1)
    P = P / row_sums[:, np.newaxis]

# クラスタ輸送（発現量、座標）
t_centerX_exp = P.T @ centerX_exp
t_centerX_coordinate = P.T @ centerX_coordinate

# 全データ輸送
t_X = dummyY @ t_centerX_exp + Y @ centerY_exp.T @ P.T @ centerX_exp @ (X.T @ X) - Y @ centerY_exp.T @ P.T @ centerX_exp @ (X.T @dummyX @ centerX_exp)
