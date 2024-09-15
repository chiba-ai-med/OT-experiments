import SimpleITK as sitk

fixed_image = sitk.ReadImage("pos.png", sitk.sitkFloat32)
moving_image = sitk.ReadImage("neg.png", sitk.sitkFloat32)

# 画像レジストレーションを実行
registration_method = sitk.ImageRegistrationMethod()
registration_method.SetFixedImage(fixed_image)
registration_method.SetMovingImage(moving_image)
registration_method.SetInterpolator(sitk.sitkLinear)
registration_method.SetOptimizerAsGradientDescent(learningRate=1.0, numberOfIterations=100)
registration_method.SetMetricAsMeanSquares()
registration_method.SetInitialTransform(sitk.TranslationTransform(fixed_image.GetDimension()))
transform = registration_method.Execute()

# 変形ベクトルフィールドを取得
displacement_field = sitk.TransformToDisplacementField(transform, fixed_image.GetSize(), sitk.sitkFloat32, sitk.sitkLinear)

# 変形グリッドのプロット
def plot_deformation_grid(fixed_image, displacement_field, step=10):
    fixed_np = sitk.GetArrayFromImage(fixed_image)
    disp_np = sitk.GetArrayFromImage(displacement_field)
    
    x = np.arange(0, fixed_np.shape[1], step)
    y = np.arange(0, fixed_np.shape[0], step)
    X, Y = np.meshgrid(x, y)
    
    U = disp_np[:, :, 0][Y.astype(int), X.astype(int)]
    V = disp_np[:, :, 1][Y.astype(int), X.astype(int)]
    
    plt.figure(figsize=(10, 10))
    plt.imshow(fixed_np, cmap='gray', origin='lower')
    plt.quiver(X, Y, U, V, angles='xy', scale_units='xy', scale=1, color='r')
    plt.title('Deformation Grid')
    plt.show()

# 変形フィールドを可視化
plot_deformation_grid(fixed_image, displacement_field)