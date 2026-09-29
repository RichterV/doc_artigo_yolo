# Configuration files

## `config.yml` (RGB-like representations)

The same schema is used in `rgb_drone/`, `rgb_degradado/` and `rgb_micasense/`. Values shown are the ones required for the paper.

```yaml
contextos: [32]                 # patch side in px; must be divisible by 8

imagens:
  drone_rgb:                    # raster-set name (label only)
    bandas:                     # single-band GeoTIFFs, same grid
      R: b1_red.tif             # rgb_degradado: b1_red_degradado.tif
      G: b2_green.tif           # rgb_degradado: b2_green_degradado.tif
      B: b3_blue.tif            # rgb_degradado: b3_blue_degradado.tif

feature_sets:
  executar: [rgb]               # rgb_micasense: [ms_rgb]
  definicoes:
    rgb:    {bands: [R, G, B], indices: []}
    # ms_rgb: {bands: [R, G, B], indices: []}   (rgb_micasense)

points:                         # key order = label order (0..3)
  treino:
    estressadas:   dados/treino/estressadas2.shp
    mortas:        dados/treino/mortas.shp
    saudaveis:     dados/treino/saudaveis.shp
    solo_residuos: dados/treino/solo_residuos.shp
  validacao:
    estressadas:   dados/validacao/estressadas_val2.shp
    mortas:        dados/validacao/mortas_val.shp
    saudaveis:     dados/validacao/saudaveis_val.shp
    solo_residuos: dados/validacao/solo_residuos_val.shp

modo: treino                    # treino → run 1 + 2; then validacao → run 1 + 3/5

output_dir:
  treino: context_data
  validacao: context_data_validation
model_dir: context_models
log_dir: logs
metrics_dir: metrics
random_seed: 153

normalizacao:
  percentil_inferior: 2
  percentil_superior: 98
  max_pixels_amostra: 1000000

training:
  patience: 30
  epochs: 5000
  batch_size: 16
  test_size: 0.30
  learning_rate: 0.0001
  monitor: val_loss
  augment:
    rotation_range: 20
    zoom_range: 0.2
    horizontal_flip: true

selection:                      # used only by 3_predict.py → best_model_selection.json
  metric: f1_doentes
  classes_doentes: [estressadas, mortas]
  tie_breaker: balanced_accuracy

predict:                        # used only by the mapping extra
  batch_size: 32
  window_size: 512
  raster_set: drone_rgb
  output_dir: predicoes
  shapefile_limit: dados/limite_area.shp
  min_confidence: 0.0
```

!!! danger "Keep the class order"
    The order of keys under `points.treino` defines the labels (0 = stressed, 1 = dead, 2 = healthy, 3 = soil/residue). The export and statistics scripts hard-code `CLASS_NAMES = ["estressadas", "mortas", "saudaveis", "solo_residuos"]`. The extraction script aborts if the training and validation keys differ in name or order.

## `config_multi_controlado.yml` (CCCI / PSRI)

```yaml
contextos: [32]
imagens:                        # base names; ".tif" is appended
  - CCCI_recortado
  - PSRI_recortado
modo: treino                    # then validacao
points: { ... same as above ... }
output_dir: {treino: context_data, validacao: context_data_validation}
model_dir: context_models
log_dir: logs
metrics_dir: metrics_controlado
random_seed: 153
training: { ... same values as above ... }
```

There is no `normalizacao` section, because index values are used raw.

## CLI of the statistics script

| Flag | Default | Paper value |
|---|---|---|
| `--rgb-degradado` | required | `predicoes_RGB_degradado.csv` |
| `--comparados` | required | the other four CSVs |
| `--nomes` | required | `RGB MS_RGB CCCI PSRI` |
| `--bootstrap` | 10000 | 10000 |
| `--seed` | 153 | 153 |
| `--tol` | 0.01 (m) | 0.01 |
| `--outdir` | `resultados_comparacao_rgb_degradado` | — |
