# Adapted from https://github.com/slaclab/cryosparc-docker/blob/master/Dockerfile
FROM unlhcc/xfce_ubuntu20_ood:4.14

RUN apt-get update && \
    apt-get -y install iputils-ping

ENV CRYOSPARC_ROOT_DIR /opt/cryosparc
RUN mkdir -p ${CRYOSPARC_ROOT_DIR}
WORKDIR ${CRYOSPARC_ROOT_DIR}

ARG CRYOSPARC_VERSION=4.4.1
ENV CRYOSPARC_FORCE_USER=true

# install master
ENV CRYOSPARC_MASTER_DIR ${CRYOSPARC_ROOT_DIR}/cryosparc_master
RUN --mount=type=secret,id=CRYOSPARC_LICENSE_ID\
  curl -L https://get.cryosparc.com/download/master-v${CRYOSPARC_VERSION}/$(cat /run/secrets/CRYOSPARC_LICENSE_ID) | tar -xz \
        && cd ${CRYOSPARC_MASTER_DIR} \
  && bash ./install.sh --license "$(cat /run/secrets/CRYOSPARC_LICENSE_ID)" --yes --allowroot \
  && sed -i 's/^export CRYOSPARC_LICENSE_ID=.*$/export CRYOSPARC_LICENSE_ID=TBD/g' ${CRYOSPARC_MASTER_DIR}/config.sh

# install worker
ENV CRYOSPARC_WORKER_DIR ${CRYOSPARC_ROOT_DIR}/cryosparc_worker
RUN --mount=type=secret,id=CRYOSPARC_LICENSE_ID\
  curl -L https://get.cryosparc.com/download/worker-v${CRYOSPARC_VERSION}/$(cat /run/secrets/CRYOSPARC_LICENSE_ID) | tar -xz \
  && cd ${CRYOSPARC_WORKER_DIR} \
  && bash ./install.sh --license "$(cat /run/secrets/CRYOSPARC_LICENSE_ID)" --yes --standalone \
  && sed -i 's/^export CRYOSPARC_LICENSE_ID=.*$/export CRYOSPARC_LICENSE_ID=TBD/g' ${CRYOSPARC_WORKER_DIR}/config.sh 

ENV PATH=/opt/cryosparc/cryosparc_master/bin:/opt/cryosparc/cryosparc_worker/bin:$PATH
