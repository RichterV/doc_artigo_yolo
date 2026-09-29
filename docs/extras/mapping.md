# Wall-to-wall mapping

`4_pos_processamento_shps.py` applies the winning model from `best_model_selection.json` (written by `3_predict.py`) to **every pixel** inside `dados/limite_area.shp`. It writes **one polygon shapefile per class**; no raster is created.

How it works:

1. The stand's bounding window is split into non-overlapping core windows of `predict.window_size` px (default 512).
2. Each core is read with a **halo** of 16 px (half the context), clipped to the raster, and edge-padded by replication where the halo leaves the raster.
3. Features are computed and normalised with the training JSON (`bands_indices.montar_atributos`).
4. Every core pixel inside the boundary becomes the centre of a 32 × 32 patch. Patches are predicted in batches of `predict.batch_size`. Pixels below `min_confidence` stay unclassified.
5. The label array of the window is vectorised (`rasterio.features.shapes`) and appended straight to the per-class shapefiles, then freed.

Optional `pos_processamento` keys in `config.yml`:

| Key | Default | Effect |
|---|---|---|
| `filtrar_poligonos` / `min_area_poligonos` | true / 0 | drop polygons smaller than the area (map units²) |
| `filtrar_aneis` / `min_area_aneis` | true / 0 | fill holes smaller than the area |
| `simplificar_geometria` / `tolerancia_simplify` | true / 0 | Douglas–Peucker simplification |
| `validar_geometria` | true | `make_valid` on every polygon |

```bash
cd linux/rgb_drone
python 3_predict.py                 # writes best_model_selection.json
python 4_pos_processamento_shps.py  # → predicoes/*.shp
```

A per-pixel classification with a 32 × 32 context runs one forward pass per pixel. For an 11 ha stand at 3.25 cm that is about 10⁸ patches, so expect hours on a small GPU.
