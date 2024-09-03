#!/usr/bin/env bash

if command -v conda > /dev/null 2>&1; then
    conda deactivate > /dev/null 2>&1 || true  # ignore any errors
    conda deactivate > /dev/null 2>&1 || true  # ignore any errors
fi
unset _CE_CONDA
unset CONDA_DEFAULT_ENV
unset CONDA_EXE
unset CONDA_PREFIX
unset CONDA_PROMPT_MODIFIER
unset CONDA_PYTHON_EXE
unset CONDA_SHLVL
unset PYTHONPATH
unset LD_PRELOAD
export LD_LIBRARY_PATH=/.singularity.d/libs

source /opt/conda/etc/profile.d/conda.sh
conda activate /opt/deepEMhancer_env
exec deepemhancer $@
