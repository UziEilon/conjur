#!/bin/bash -ex

# Given platform as a positional argument, runs authn-k8s tests against a live K8S cluster
# Expects environment variables to be passed in via summon

#!/bin/bash -euf
set -o pipefail

PLATFORM="$1"  # k8s platform

function main() {
  setupTestEnvironment "$PLATFORM"

  createNginxCert
    
  buildDockerImages

  case "$PLATFORM" in
    gke)
      test_gke
      ;;
    openshift*)
      test_openshift
      ;;
    *)
      echo "'$PLATFORM' is not a supported test platform"
      exit 1
  esac
}

function setupTestEnvironment() {
  CONJUR_AUTHN_K8S_TEST_NAMESPACE="test-$(uuidgen | tr "[:upper:]" "[:lower:]")"
  export CONJUR_AUTHN_K8S_TEST_NAMESPACE

  case "$PLATFORM" in
    gke)
      export DOCKER_REGISTRY_PATH="gcr.io/$GCLOUD_PROJECT_NAME"
      ;;
    openshift*)
      export DOCKER_REGISTRY_PATH="$OPENSHIFT_REGISTRY_URL/$CONJUR_AUTHN_K8S_TEST_NAMESPACE"
      ;;
    *)
      echo "'$PLATFORM' is not a supported test platform"
      exit 1
  esac

  export PLATFORM

  export CONJUR_AUTHN_K8S_TAG="${DOCKER_REGISTRY_PATH}/conjur:authn-k8s-\
$CONJUR_AUTHN_K8S_TEST_NAMESPACE"
  export CONJUR_TEST_AUTHN_K8S_TAG="${DOCKER_REGISTRY_PATH}/conjur-test:\
authn-k8s-$CONJUR_AUTHN_K8S_TEST_NAMESPACE"
  export CONJUR_AUTHN_K8S_TESTER_TAG="${DOCKER_REGISTRY_PATH}/authn-k8s-tester:\
$CONJUR_AUTHN_K8S_TEST_NAMESPACE"

  export INVENTORY_TAG="${DOCKER_REGISTRY_PATH}/inventory:$CONJUR_AUTHN_K8S_TEST_NAMESPACE"

  export NGINX_TAG="${DOCKER_REGISTRY_PATH}/nginx:$CONJUR_AUTHN_K8S_TEST_NAMESPACE"
}

function createNginxCert() {
  docker pull svagi/openssl

  docker run --rm -i \
         -w /home -v "$PWD/dev/tls:/home" \
         svagi/openssl req\
         -x509 \
         -nodes \
         -days 365 \
         -newkey rsa:2048 \
         -config /home/tls.conf \
         -extensions v3_ca \
         -keyout nginx.key \
         -out nginx.crt
}

function buildDockerImages() {
  conjur_version=$(echo "$(< ../../VERSION)-$(git rev-parse --short HEAD)")

  docker tag "conjur:$conjur_version" "$CONJUR_AUTHN_K8S_TAG"

  # cukes will be run from this image
  docker tag "conjur-test:$conjur_version" "$CONJUR_TEST_AUTHN_K8S_TAG"
  
  docker build -t "$INVENTORY_TAG" -f dev/Dockerfile.inventory dev

  docker build -t "$NGINX_TAG" -f dev/Dockerfile.nginx dev

  docker build \
    --build-arg "OPENSHIFT_CLI_URL=$OPENSHIFT_CLI_URL" \
    --tag "$CONJUR_AUTHN_K8S_TESTER_TAG" \
    --file dev/Dockerfile.test dev
}

function test_gke() {
  docker run --rm \
    --env CONJUR_AUTHN_K8S_TAG \
    --env CONJUR_TEST_AUTHN_K8S_TAG \
    --env INVENTORY_TAG \
    --env NGINX_TAG \
    --env CONJUR_AUTHN_K8S_TEST_NAMESPACE \
    --env GCLOUD_CLUSTER_NAME \
    --env GCLOUD_PROJECT_NAME \
    --env "GCLOUD_SERVICE_KEY=/tmp$GCLOUD_SERVICE_KEY" \
    --env GCLOUD_ZONE \
    --volume "$GCLOUD_SERVICE_KEY:/tmp$GCLOUD_SERVICE_KEY" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$PWD":/src \
    "$CONJUR_AUTHN_K8S_TESTER_TAG" bash -c "./test_gke_entrypoint.sh"
}

function test_openshift() {
  docker run --rm \
    --env CONJUR_AUTHN_K8S_TAG \
    --env CONJUR_TEST_AUTHN_K8S_TAG \
    --env INVENTORY_TAG \
    --env NGINX_TAG \
    --env CONJUR_AUTHN_K8S_TEST_NAMESPACE \
    --env PLATFORM \
    --env K8S_VERSION \
    --env OPENSHIFT_URL \
    --env OPENSHIFT_REGISTRY_URL \
    --env OPENSHIFT_USERNAME \
    --env OPENSHIFT_PASSWORD \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$PWD":/src \
    "$CONJUR_AUTHN_K8S_TESTER_TAG" bash -c "./test_oc_entrypoint.sh"
}

main
