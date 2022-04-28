# simple build image

![image](https://user-images.githubusercontent.com/85586/165821692-f6692cc2-49f9-4fca-9b57-4797ebbb14d7.png)


A github action to build and deploy clabs kubernetes based apps to GCR + GKE via helm charts.

The image is a simple container with the google cloud sdk and helm installed, plus a series of basic bash scripts to perform build and deployment tasks.

This action and it's image are versioned with a rolling release setup i.e. the most recent version should always be used. The action will pull in the most recent version of the build image, but changes to the github action itself may require an update of version tags.

# Usage

## Github CI Config

Add the github action to your ci config. The below example assumes usage of [github's environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) features to store credentials for deployment environments.

```yaml
deploy:
  name: SBI Deploy
  needs: <test task or other stuff that must pass before deployment>
  environment:
    name: <github_environment_name>
  steps:
    - uses: actions/checkout@v2 # checkout the repo for this step
    - name: Deploy
      uses: celo-org/sbi@v0.2 # run the build + deploy task
      env:
        GCLOUD_CREDENTIALS: ${{ secrets.GCLOUD_CREDENTIALS }}
        NAMESPACE: ${{ secrets.NAMESPACE }}
        PROJECT: ${{ secrets.PROJECT }}
        CLUSTER: ${{ secrets.CLUSTER }}
        SLACK_API_TOKEN: ${{ secrets.SLACK_API_TOKEN }}
        SLACK_CHANNEL_IDS: ${{ secrets.SLACK_CHANNEL_IDS }}
```

Values required for the environment variables are outlined in the documentation section.

## Project Structure

The build image expects a convention in directory structure, where there is an `ops` directory at the root of the project, containing the `Dockerfile` and helm templates for the application.

In practice this looks something like the below.

```
ops
├── Dockerfile
└── helm
    ├── Chart.yaml
    ├── charts
    ├── templates
    │   ├── NOTES.txt
    │   ├── _helpers.tpl
    │   ├── deployment.yaml
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── service.yaml
    │   └── serviceaccount.yaml
    └── values.yaml
```

Many of these locations can be overridden via env variables during build + deploy.

## Credentials

You need a service account with the following roles applied

- `roles/storage.admin`
  - To create and push new images
  - <https://cloud.google.com/container-registry/docs/access-control#grant>
- `roles/container.developer`
  - To interact with the k8s cluster and effect manifest changes

Credentials for this service account should be provided in json format via the `GCLOUD_CREDENTIALS` environment var to the action.

### Notifications

Optionally, build success notifications can be sent to a set of chosen slack channels. This requires a token for slack api access and a list of channel ids to post to.

These should be provided via `SLACK_API_TOKEN` and `SLACK_CHANNEL_IDS` environment vars.

# Documentation

## Variables

| Required | Var Name             | Description                                                    | Default Value                                                                         |
|----------|----------------------|----------------------------------------------------------------|---------------------------------------------------------------------------------------|
|          | `NAME`               | The name of the app, used in helm's release name               | The name of the repository on Github - provided at build time via `GITHUB_REPOSITORY` |
|          | `COMMITSH`           | The version of the app to build and deploy                     | The value of the current HEAD on Github - provided via `GITHUB_SHA`                   |
| ❗️        | `GCLOUD_CREDENTIALS` | The json credentials for the service account                   | None                                                                                 |
|          | `RELEASE_NAME`       | The release name for helm                                      | "`NAMESPACE`-`NAME`"                                                                  |
|          | `DOCKERFILE`         | The path to the Dockerfile that builds the container to deploy | `PROJECT_ROOT/ops/Dockerfile`                                                         |
|          | `DOCKERPATH`         | The path to the docker build context                           | `PROJECT_ROOT`                                                                        |
|          | `REGISTRY_URL`       | The url of the docker registry you wish to push to.            | `gcr.io/celo-testnet`                                                                 |
|          | `CHART_DIR`          | The path to the helm chart.                                    | `PROJECT_ROOT/ops/helm`                                                               |
|          | `MANIFESTS_DIR`      | The tmp path to the manifests to generate                      | `/tmp/manifests`                                                                      |
|          | `PROJECT`            | The GCP project of your credentials.                           |                                                                                       |
|          | `ZONE`               | The availability zone of your credentials                      |                                                                                       |
| ❗️        | `CLUSTER`            | The k8s cluster you are deploying to.                          |                                                                                      |
| ❗️        | `NAMESPACE`          | The k8s namespace to deploy to.                                |     


# Development

> todo:
- how to build and release this
- when tags need to change (github action)
- how to run locally

# Limitations

- does not handle k8s secrets
- Assumes a single docker image per repository

# Todo

- test environment yaml priorities
- look at bash tests
- remove slack notifications and replace with cloud functions
- create custom gcp roles with minimal subset of permissions for deployment
    - possibly remove editor role after first deploy via cloud function
- send pubsub messages on start, finish and failure  
- reduce image size
  - google cloud sdk is massive
