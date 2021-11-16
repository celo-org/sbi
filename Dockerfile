FROM docker:stable-git

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    make \
    py-pip \
    openssl

ARG HELM_RELEASE=helm-v3.6.3-linux-amd64.tar.gz
RUN curl -LO https://get.helm.sh/${HELM_RELEASE} \
    && tar -xzf ${HELM_RELEASE} \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf ${HELM_RELEASE} linux-amd64

ARG GCLOUD_RELEASE=google-cloud-sdk-364.0.0-linux-x86_64.tar.gz
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${GCLOUD_RELEASE} \
    && tar -xf ${GCLOUD_RELEASE} \
    && /google-cloud-sdk/install.sh -q --additional-components kubectl kubectl-oidc docker-credential-gcr \
    && rm -fr ${GCLOUD_RELEASE}

ENV PATH="/google-cloud-sdk/bin:${PATH}"

ADD script /script

