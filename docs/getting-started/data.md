# Input data

The repository holds the code, the validation shapefiles, the stand boundary and the final prediction CSVs. The **rasters, the complete training shapefiles and the trained models are not included** and must be provided separately.

## Inventory

| Item | Format | Where it comes from | In the repo? |
|---|---|---|---|
| Phantom 4 Adv+ RGB orthomosaic, 3.25 cm | GeoTIFF, 3 bands | Metashape ([step 1](../pipeline/01-imagery.md)) | :x: |
| RedEdge-MX reflectance orthomosaic, 8.41 cm (B, G, R, RE, NIR) | GeoTIFF, 5 files, 1 band each | Metashape ([step 1](../pipeline/01-imagery.md)) | :x: |
| `CCCI_recortado.tif`, `PSRI_recortado.tif` | GeoTIFF, 1 band, float | QGIS raster calculator + clip ([step 2](../pipeline/02-representations.md#cccipsri)) | :x: |
| Training points, 4 shapefiles (one per class) | Point shapefile | QGIS ([step 3](../pipeline/03-reference-data.md)) | :warning: older version, see below |
| Validation points, 4 shapefiles | Point shapefile | QGIS ([step 3](../pipeline/03-reference-data.md)) | :white_check_mark: `linux/rgb_micasense/dados/validacao/` |
| Stand boundary `limite_area.shp` | Polygon shapefile | QGIS | :white_check_mark: `linux/rgb_micasense/dados/` |
| Final predictions (5 CSVs) | CSV | Step 7 | :white_check_mark: `linux/comparacao/` |

**CRS:** all rasters and vectors must use **WGS 84 / UTM zone 21S (EPSG:32721)**. The extraction scripts reproject points on the fly when their CRS differs, but the rasters must already share one grid within each representation.

!!! danger "Training shapefiles in `dados/treino/` are not the final set"
    The shapefiles in `linux/rgb_micasense/dados/treino/` contain **2,991** points (450 stressed, 159 dead, 1,481 healthy, 901 soil/residue). The paper's model-development set has **3,818** (548 / 176 / 1,794 / 1,300), split 2,672 fitting + 1,146 internal holdout. Replace these files with the final training shapefiles before training. The validation shapefiles (591 points, 571 once edge patches are discarded) **do** match the paper.

## Reference point files

The class order is fixed by the order of the keys in `config.yml`, and it sets the integer label:

| Label | Class key (PT) | Class (EN) | Training file | Validation file | Training n (paper) | Validation n (paper) |
|---|---|---|---|---|---|---|
| 0 | `estressadas` | stressed (RMD) | `dados/treino/estressadas2.shp` | `dados/validacao/estressadas_val2.shp` | 548 | 85 |
| 1 | `mortas` | dead | `dados/treino/mortas.shp` | `dados/validacao/mortas_val.shp` | 176 | 18 |
| 2 | `saudaveis` | healthy | `dados/treino/saudaveis.shp` | `dados/validacao/saudaveis_val.shp` | 1,794 | 231 |
| 3 | `solo_residuos` | soil/residue | `dados/treino/solo_residuos.shp` | `dados/validacao/solo_residuos_val.shp` | 1,300 | 237 |
| | | | | **Total** | **3,818** | **571** |

Only the **geometry** of each file is read, and it must be `Point`; attribute columns are ignored. Put one point at the centre of each crown or reference location. Points of different classes must not overlap.

## Expected layout of each working folder

Each script reads `config.yml` from the **current working directory** and resolves every path relative to it. Copy `dados/` into each representation folder, or create a symlink there.

```text
linux/
├── rgb_drone/              # 1 · native broadband RGB (3.25 cm)
│   ├── config.yml
│   ├── bands_indices.py    # ← copy from rgb_micasense/ (missing here)
│   ├── b1_red.tif  b2_green.tif  b3_blue.tif     # Phantom RGB, single-band files
│   └── dados/ {treino/, validacao/, limite_area.shp}
├── rgb_degradado/          # 2 · harmonized broadband RGB (8.41 cm)
│   ├── config.yml
│   ├── bands_indices.py    # ← copy from rgb_micasense/ (missing here)
│   ├── harmonize_rgb_to_rededge_explicit.py
│   ├── b1_red_degradado.tif  b2_green_degradado.tif  b3_blue_degradado.tif
│   └── dados/
├── rgb_micasense/          # 3 · narrowband RGB (RedEdge-MX B, G, R)
│   ├── config.yml
│   ├── bands_indices.py
│   ├── b1_red.tif  b2_green.tif  b3_blue.tif     # RedEdge-MX 668/560/475 nm bands
│   └── dados/
├── IVs/                    # 4–5 · CCCI and PSRI
│   ├── config_multi_controlado.yml
│   ├── CCCI_recortado.tif  PSRI_recortado.tif
│   └── dados/
└── comparacao/             # paired statistics
    └── predicoes_*.csv
```

!!! warning "`bands_indices.py` must be copied"
    `rgb_drone/` and `rgb_degradado/` import `bands_indices` but do not contain the module. Copy `linux/rgb_micasense/bands_indices.py` into both folders, or the scripts fail with `ModuleNotFoundError`.

!!! note "Same file names, different sensors"
    `rgb_drone/b1_red.tif` is the **Phantom broadband** red band. `rgb_micasense/b1_red.tif` is the **RedEdge-MX narrow** red band (668 nm). Keep the two folders strictly separate.

## Raster requirements checked by the code

For the three RGB representations (`bands_indices.validar_grade`):

- each of `R`, `G` and `B` is a **single-band** GeoTIFF;
- all three share the same width, height, CRS and affine transform;
- any data type is accepted, because values are read as `float32`. Pixels masked as nodata become `NaN`, and a pixel with `R = G = B = 0` counts as outside the mosaic.

For the index rasters (`IVs/1_extract_multi_com_id.py`):

- a single-band GeoTIFF named `<name>.tif`, where `<name>` is listed under `imagens:` in the config;
- nodata outside the clipped stand, so that edge patches become `NaN` and are discarded.
