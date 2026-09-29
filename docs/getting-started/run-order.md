# Run order (cheat sheet)

Every command below runs **inside the folder named in its heading**. Steps marked :material-pencil: mean you edit a config file before running.

!!! warning "Apply the paper-conformity patches first"
    Before training, apply patches **P1–P3** in [Paper vs. code](../reference/paper-vs-code.md): stratified split, oversampling of the fitting subset, and seeded augmentation. Apply **P4** (16-test Holm family) before the statistics. Without them the pipeline still runs, but it does not follow the published method.

## 0 · Prepare rasters (once)

```bash
# Split the Phantom RGB orthomosaic into single-band files
cd linux/rgb_drone
gdal_translate -b 1 rgb_orthomosaic.tif b1_red.tif
gdal_translate -b 2 rgb_orthomosaic.tif b2_green.tif
gdal_translate -b 3 rgb_orthomosaic.tif b3_blue.tif

# Harmonize the RGB bands to the RedEdge-MX grid (edit the paths at the top of the script first)
cd ../rgb_degradado
cp ../rgb_micasense/bands_indices.py . && cp ../rgb_micasense/bands_indices.py ../rgb_drone/
python harmonize_rgb_to_rededge_explicit.py
```

Compute `CCCI_recortado.tif` and `PSRI_recortado.tif` in QGIS and copy them to `linux/IVs/` (see [step 2](../pipeline/02-representations.md#cccipsri)).

## 1–3 · The three RGB-like representations

Repeat this block for **`rgb_drone`** (native), **`rgb_degradado`** (harmonized) and **`rgb_micasense`** (narrowband):

```bash
cd linux/<folder>

# EDIT: config.yml → modo: treino   (and feature_sets.executar: [rgb] in rgb_drone)
python 1_extract_train_data_from_points.py     # training patches + normalisation JSON
python 2_train.py                              # trains U-Net++ → context_models/<fs>/best_model_32_<fs>.keras

# EDIT: config.yml → modo: validacao
python 1_extract_train_data_from_points.py     # validation patches with the TRAINING normalisation
python 3_predict.py                            # optional: metrics + confusion matrices (metrics/)
```

Then export the per-observation predictions:

=== "rgb_drone (native)"

    ```bash
    python 5_exportar_predicoes.py --nome RGB \
      --model   context_models/rgb/best_model_32_rgb.keras \
      --x       context_data_validation/X_context_32_rgb.npy \
      --y       context_data_validation/Y_labels_32_rgb.npy \
      --samples context_data_validation/samples_32.csv
    ```

=== "rgb_degradado (harmonized)"

    ```bash
    python 5_exportar_predicoes.py --nome RGB_degradado \
      --model   context_models/rgb/best_model_32_rgb.keras \
      --x       context_data_validation/X_context_32_rgb.npy \
      --y       context_data_validation/Y_labels_32_rgb.npy \
      --samples context_data_validation/samples_32.csv
    ```

=== "rgb_micasense (narrowband)"

    ```bash
    python 5_exportar_predicoes_ms_rgb.py --nome MS_RGB \
      --model   context_models/ms_rgb/best_model_32_ms_rgb.keras \
      --x       context_data_validation/X_context_32_ms_rgb.npy \
      --y       context_data_validation/Y_labels_32_ms_rgb.npy \
      --samples context_data_validation/samples_32.csv
    ```

Output: `predicoes_individuais/predicoes_<nome>.csv` (plus `.xlsx`).

## 4–5 · CCCI and PSRI

```bash
cd linux/IVs
# EDIT: config_multi_controlado.yml → modo: treino
python 1_extract_multi_com_id.py
python 2_train_multi_controlado.py
# EDIT: config_multi_controlado.yml → modo: validacao
python 1_extract_multi_com_id.py
python 3_exportar_predicoes_com_matriz.py      # → predicoes_individuais/predicoes_{CCCI,PSRI}.csv
```

## 6 · Paired statistics

```bash
cd linux/comparacao
cp ../rgb_drone/predicoes_individuais/predicoes_RGB.csv .
cp ../rgb_degradado/predicoes_individuais/predicoes_RGB_degradado.csv .
cp ../rgb_micasense/predicoes_individuais/predicoes_MS_RGB.csv .
cp ../IVs/predicoes_individuais/predicoes_{CCCI,PSRI}.csv .

python 4_comparacao_estatistica_rgb_degradado.py \
  --rgb-degradado predicoes_RGB_degradado.csv \
  --comparados predicoes_RGB.csv predicoes_MS_RGB.csv predicoes_CCCI.csv predicoes_PSRI.csv \
  --nomes RGB MS_RGB CCCI PSRI \
  --bootstrap 10000 --seed 153 --tol 0.01 \
  --outdir resultados_comparacao_rgb_degradado
```

Compare the outputs with [Expected results](../pipeline/09-expected-results.md).

## Checklist

- [ ] Final training shapefiles (3,818 points) placed in every `dados/treino/`
- [ ] `bands_indices.py` copied to `rgb_drone/` and `rgb_degradado/`
- [ ] Patches P1–P3 applied to both training scripts
- [ ] `rgb_drone/config.yml` uses `executar: [rgb]`
- [ ] Each folder run first with `modo: treino`, then `modo: validacao`
- [ ] Validation `X` has **571** samples at 8.41 cm (589 for native RGB)
- [ ] Patch P4 applied before running the statistics
