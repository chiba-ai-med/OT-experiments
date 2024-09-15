import ants
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt

def load_png_as_antspy_image(file_path):
	image = Image.open(file_path).convert('L')
	image_np = np.rot90(np.array(image), k=1)
	antspy_image = ants.from_numpy(image_np)
	return antspy_image

fixed = load_png_as_antspy_image("pos.png")
moving__ = load_png_as_antspy_image("neg.png")

# Rescale
original_size = moving__.shape
new_size = (int(original_size[0]*1.2), int(original_size[1]*0.7))
moving_ = ants.resample_image(moving__, resample_params=new_size, use_voxels=True)

# Slide
transform = ants.create_ants_transform(
	dimension=2,
	translation=[10,10]
)
transform_file = "translation_transform.txt"
ants.write_transform(transform, transform_file)

moving = ants.apply_transforms(
	fixed=moving_,
	moving=moving_,
	transformlist=[transform_file],
	interpolation='nearestNeighbor'
)

# Registration
mytx = ants.registration(fixed=fixed, moving=moving, type_of_transform='SyN' )
warped_moving = mytx['warpedmovout']

# Plot
ants.plot(fixed, title="Positive", filename="fixed.png")
ants.plot(moving, title="Negative", filename="moving.png")
fixed.plot(overlay=warped_moving, title='After Registration', filename="warped_moving.png")

# 変形画像を生成するために変形フィールドを取得
displacement_field = ants.apply_transforms(fixed=fixed, moving=moving, transformlist=mytx['fwdtransforms'])

# グリッドの間隔
step = 10

# グリッド点の生成
x = np.arange(0, fixed.shape[1], step)
y = np.arange(0, fixed.shape[0], step)
X, Y = np.meshgrid(x, y)

# 変形ベクトルの計算
displacement = displacement_field.numpy()
X_flat = X.flatten()
Y_flat = Y.flatten()

# 変形後の座標を計算
X_deformed = X_flat + displacement[Y_flat.astype(int), X_flat.astype(int)]
Y_deformed = Y_flat + displacement[Y_flat.astype(int), X_flat.astype(int)]

# プロット
plt.figure(figsize=(10, 10)); plt.quiver(X, Y, X_deformed.reshape(X.shape) - X.reshape(X.shape), Y_deformed.reshape(Y.shape) - Y.reshape(Y.shape), angles='xy', scale_units='xy', scale=1, color='r'); plt.title('Deformation Grid');plt.show()

# Ref
# https://notebook.community/ANTsX/ANTsPy/tutorials/10minTutorial