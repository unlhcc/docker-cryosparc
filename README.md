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

Release Branches
----------------

Each CryoSPARC minor release (i.e X.Y) is contained within its own protected `release-X.Y` branch.  Those branches
will automatically build and push the tagged images to the container registry with the appropriate bugfix
tag.  When updating bugfix releases be sure to update the `CRYOSPARC_VERSION` variable in the CI config
file.
