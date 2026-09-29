# RMD Spatial–Spectral Classification — Reproduction Guide

MkDocs Material documentation for reproducing the experiment in
*Spatial–spectral trade-offs in RPAS-based phytosanitary classification of* Eucalyptus saligna.
It compares native broadband RGB, spatially harmonized RGB, narrowband RGB, CCCI and PSRI with a common U-Net++ classifier and paired statistics.

## Build the site locally

```bash
pip install -r requirements-docs.txt
mkdocs serve        # http://127.0.0.1:8000
mkdocs build        # static site in ./site
```

## Layout

- `docs/`: documentation sources
- `mkdocs.yml`: site configuration
- `requirements.txt`: Python environment for the pipeline (TensorFlow 2.13, Python 3.10)
- `requirements-docs.txt`: dependencies for building the docs
- `commit.sh`: builds the site, then commits and pushes the documentation to GitHub
