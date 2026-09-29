# Getting started

Reproducing the experiment has three prerequisites:

1. **[A compatible Python environment](environment.md).** TensorFlow 2.13 does not run on the Python 3.12 that ships with Ubuntu 24.04, so you need a separate interpreter.
2. **[The input data](data.md):** RGB and RedEdge-MX orthomosaics, the two index rasters, and the reference point shapefiles, all named and placed where the scripts expect them.
3. **[The run order](run-order.md):** the scripts are small, single-purpose, and driven by a `config.yml` in the current working directory. They must run in a fixed sequence, and you have to switch the `modo` (mode) key between runs.

!!! note "Language of the code"
    Script names, variables, console messages and configuration keys are in **Portuguese** (for example `modo: treino` = *mode: training*, `estressadas` = *stressed*). The [glossary](../reference/glossary.md) translates every term you will meet.
