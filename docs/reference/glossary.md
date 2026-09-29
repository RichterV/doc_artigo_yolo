# Glossary (PT → EN)

## Classes

| Code | English |
|---|---|
| `estressadas` | stressed (RMD-symptomatic) |
| `mortas` | dead |
| `saudaveis` | healthy |
| `solo_residuos` | soil/residue |
| `doentes` (`classes_doentes`) | diseased = stressed + dead (only used for the model selection in `3_predict.py`) |

## Representations and folders

| Code | English / meaning |
|---|---|
| `rgb_drone` | native broadband RGB (Phantom camera, 3.25 cm) |
| `rgb_degradado`, `RGB_degradado` | *degraded* RGB = **spatially harmonized** broadband RGB (8.41 cm) |
| `rgb_micasense`, `ms_rgb`, `MS_RGB` | narrowband RGB (RedEdge-MX B, G, R) |
| `IVs` (*índices de vegetação*) | vegetation indices: CCCI, PSRI (or, in `rgb_drone`, RGB indices) |
| `*_recortado` | clipped (to the stand boundary) |
| `comparacao` | comparison (statistics) |

## Config keys and file names

| Code | English |
|---|---|
| `modo: treino` / `modo: validacao` | mode: training / validation |
| `contextos` | contexts = patch sizes in pixels |
| `imagens`, `bandas` | images, bands |
| `feature_sets.executar` / `definicoes` | feature sets to run / definitions |
| `points.treino` / `points.validacao` | training / validation point shapefiles |
| `normalizacao.percentil_inferior/superior` | lower / upper percentile |
| `max_pixels_amostra` | max pixels sampled to fit the normalisation |
| `dados/` | data |
| `limite_area` | area boundary (stand polygon) |
| `predicoes`, `predicoes_individuais` | predictions, per-observation predictions |
| `resultados`, `historico_treinamento` | results, training history |
| `matriz_confusao` | confusion matrix |
| `metricas_por_classe` / `metricas_globais` | per-class / global metrics |
| `pares`, `pareamento` | pairs, pairing |
| `resumo` | summary |
| `descartes` | discarded samples |

## Output columns

| Code | English |
|---|---|
| `classe`, `classe_real` | class, true class |
| `pred_<m>` / `pred_<m>_id` | predicted class name / index |
| `conf_<m>` | max softmax probability |
| `prob_<m>_<class>` | softmax probability of the class |
| `RGB_degradado_certo_COMPARADO_errado` | McNemar *b*: reference right, alternative wrong |
| `RGB_degradado_errado_COMPARADO_certo` | McNemar *c*: reference wrong, alternative right |
| `p_exato`, `p_holm` | exact p-value, Holm-adjusted p-value |
| `IC95_inf`, `IC95_sup` | lower / upper 95 % CI bound |
| `delta_<m>_menos_RGB_degradado` | Δ = alternative − harmonized RGB |
| `metodo_pareamento`, `distancia_pareamento` | pairing method, pairing distance |
