# Adapted from https://github.com/slaclab/cryosparc-docker/blob/master/Dockerfile
FROM unlhcc/xfce_ubuntu20_ood:4.14

RUN apt-add-repository -r "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main"
RUN apt-get update && \
    apt-get -y install iputils-ping

ENV CRYOSPARC_ROOT_DIR /opt/cryosparc
RUN mkdir -p ${CRYOSPARC_ROOT_DIR}
WORKDIR ${CRYOSPARC_ROOT_DIR}

ARG CRYOSPARC_VERSION=4.6.0
#ARG CRYOSPARC_PATCH='v4.5.3+240807'
ENV CRYOSPARC_FORCE_USER=true

# install master
ENV CRYOSPARC_MASTER_DIR ${CRYOSPARC_ROOT_DIR}/cryosparc_master
RUN --mount=type=secret,id=CRYOSPARC_LICENSE_ID\
  curl -L https://get.cryosparc.com/download/master-v${CRYOSPARC_VERSION}/$(cat /run/secrets/CRYOSPARC_LICENSE_ID) | tar -xz \
        && cd ${CRYOSPARC_MASTER_DIR} \
  && bash ./install.sh --license "$(cat /run/secrets/CRYOSPARC_LICENSE_ID)" --yes --allowroot \
  && sed -i 's/^export CRYOSPARC_LICENSE_ID=.*$/export CRYOSPARC_LICENSE_ID=TBD/g' ${CRYOSPARC_MASTER_DIR}/config.sh

## patch master
#RUN cd ${CRYOSPARC_MASTER_DIR} && \
#    curl -sSL https://get.cryosparc.com/patch_get/${CRYOSPARC_PATCH}/master | tar -xz --overwrite --strip-components=1 --directory ./

# install worker
ENV CRYOSPARC_WORKER_DIR ${CRYOSPARC_ROOT_DIR}/cryosparc_worker
RUN --mount=type=secret,id=CRYOSPARC_LICENSE_ID\
  curl -L https://get.cryosparc.com/download/worker-v${CRYOSPARC_VERSION}/$(cat /run/secrets/CRYOSPARC_LICENSE_ID) | tar -xz \
  && cd ${CRYOSPARC_WORKER_DIR} \
  && bash ./install.sh --license "$(cat /run/secrets/CRYOSPARC_LICENSE_ID)" --yes --standalone \
  && sed -i 's/^export CRYOSPARC_LICENSE_ID=.*$/export CRYOSPARC_LICENSE_ID=TBD/g' ${CRYOSPARC_WORKER_DIR}/config.sh 

## patch worker
#RUN cd ${CRYOSPARC_WORKER_DIR} && \
#    curl -sSL https://get.cryosparc.com/patch_get/${CRYOSPARC_PATCH}/worker | tar -xz --overwrite --strip-components=1 --directory ./

# patch Topaz runner to limit number of processes to 1
ADD 001-run_topazpy-4.5.3.patch /opt/cryosparc/cryosparc_worker/cryosparc_compute/jobs/topaz
RUN pushd /opt/cryosparc/cryosparc_worker/cryosparc_compute/jobs/topaz && \
    patch < 001-run_topazpy-4.5.3.patch

ENV PATH=/opt/cryosparc/cryosparc_master/bin:/opt/cryosparc/cryosparc_worker/bin:$PATH

# Install Miniconda package manger.
RUN wget -q -P /tmp https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Create cryosparc-tools conda environment
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create -c conda-forge -c anaconda -p /opt/cryosparc-tools -y \
    pyqt=5 python=3 numpy=1.18.5 libtiff wxPython=4.1.1 adwaita-icon-theme 'setuptools<66'
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate /opt/cryosparc-tools && \
    pip install cryosparc-tools && \
    pip install nvidia-pyindex && \
    pip install 'cryolo[c11]' && \
    conda install -y -c conda-forge --freeze-installed notebook && \
    conda clean -yaq

# Create topaz environment and add wrapper
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create -p /opt/topaz -y \
    python=3.6
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate /opt/topaz && \
    conda install -y -c tbepler -c pytorch topaz=0.2.5 && \
    conda clean -yaq
COPY topaz.sh /usr/local/bin

# Create deepemhancer environment and add wrapper
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create -p /opt/deepEMhancer_env -y \
    python=3.9
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate /opt/deepEMhancer_env && \
    conda install -y -c hcc -c conda-forge deepemhancer=0.0.2023.08.23 cudatoolkit=11.4 && \
    conda clean -yaq
COPY deepemhancer.sh /usr/local/bin

ENV PATH=/opt/cryosparc-tools/bin:$PATH
