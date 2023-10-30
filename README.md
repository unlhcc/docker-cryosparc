HCC CryoSparc Docker image
==========================

CyroSparc Docker image for using on HCC resources under the CryoSparc OpenOnDemand App (via Apptainer).

Building Locally
----------------

To build the image locally, run
```
export DOCKER_BUILDKIT=1
export CRYOSPARC_LICENSE_ID=XXXXXX
docker build  --progress=plain --secret id=CRYOSPARC_LICENSE_ID .
```

replacing `XXXXXX` with a valid CryoSparc license ID.
