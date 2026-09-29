# Environment

## Versions used in the paper

| Component | Version |
|---|---|
| OS | Ubuntu 24.04 |
| TensorFlow / Keras | 2.13.1 / 2.13.1 |
| GeoPandas | 0.14.4 |
| Rasterio | 1.3.9 |
| scikit-learn | 1.3.2 |
| pandas | 2.0.3 |
| Matplotlib | 3.7.5 |
| Photogrammetry | Agisoft Metashape 2.2.1 (high quality) |
| GIS | QGIS 3.44 |

Hardware used for training: Intel Core i5-12450H, 16 GB RAM and an NVIDIA RTX 2050 GPU (4 GB). A 32 × 32 input is small, so any CUDA GPU works, and so does a CPU, only more slowly.

## Create the environment

TensorFlow 2.13 supports Python 3.8–3.11. **Python 3.10** is compatible with every pinned package above.

=== "uv"

    ```bash
    uv venv --python 3.10 .venv
    source .venv/bin/activate
    uv pip install -r requirements.txt
    ```

=== "conda"

    ```bash
    conda create -n rmd python=3.10 -y
    conda activate rmd
    pip install -r requirements.txt
    ```

Contents of `requirements.txt`:

```text
tensorflow==2.13.1          # includes keras 2.13.1
numpy==1.24.3               # highest NumPy supported by TF 2.13
geopandas==0.14.4
rasterio==1.3.9
fiona<1.10                  # used by the mapping extra; compatible with geopandas 0.14
shapely>=2.0
scikit-learn==1.3.2
scipy>=1.10,<1.12           # binomtest (exact McNemar)
pandas==2.0.3
matplotlib==3.7.5
seaborn>=0.12               # confusion-matrix heatmaps in 3_predict.py
pyyaml>=6.0
openpyxl>=3.1               # .xlsx outputs
xlsxwriter>=3.1             # .xlsx outputs in 3_predict.py
```

!!! tip "GPU"
    TF 2.13 on Linux needs CUDA 11.8 and cuDNN 8.6. The simplest route is `pip install tensorflow[and-cuda]==2.13.1`. The training scripts turn on memory growth automatically when a GPU is found.

## Check the installation

```bash
python - <<'EOF'
import tensorflow as tf, rasterio, geopandas, sklearn, pandas
print("TF", tf.__version__, "| GPUs:", tf.config.list_physical_devices("GPU"))
print("rasterio", rasterio.__version__, "| geopandas", geopandas.__version__)
print("sklearn", sklearn.__version__, "| pandas", pandas.__version__)
EOF
```

## Seeds

Every script that uses randomness is seeded with **153**:

- the `random_seed` key in each `config.yml`, used by `train_test_split`, NumPy, TensorFlow and Python's `random`;
- `--seed 153` (the default) in the bootstrap of the statistics script.

!!! warning "Remaining non-determinism"
    A fixed seed does not make GPU training bit-exact: cuDNN convolution kernels are non-deterministic. For stricter repeatability, set `TF_DETERMINISTIC_OPS=1` before training, accepting slower runs. Expect small differences in the third decimal of the metrics when you retrain. The paper did **not** measure variability across repeated initialisations.
