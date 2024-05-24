#!/bin/bash

set -euxo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
IMAGE_REGISTRY=${IMAGE_REGISTRY:="ghcr.io"}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:="ktogias/roop"}
IMAGE_TAG="0.0.1"
IMAGE=${IMAGE:="${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}:${IMAGE_TAG}"}

usage_error() {
    echo "Usage: $0 [push|test|run]"
    echo "Use 'push' to push the image."
    echo "Use 'test' to run and exec into the container."
    echo "Use 'run' to run the container."
    exit 1
}

echo "IMAGE=${IMAGE}"

docker build -t "${IMAGE}" .

run_docker() {
    local entrypoint=${1:-""}
    local options=(
    )
    [[ -n "$entrypoint" ]] && options+=(
      -it
      --entrypoint "$entrypoint"
    )
    docker run "${options[@]}" "${IMAGE}"
}

if [ $# -eq 0 ]; then
    echo "No argument provided. Only built the image."
    exit 0
fi

CMD=$1
shift || true
case "$CMD" in
    push)
        docker push "${IMAGE}"
        ;;
    test)
        run_docker /bin/bash
        ;;
    run)
        run_docker
        ;;
    *)
        echo "Invalid command: $CMD"
        usage_error
        ;;
esac

echo "Done!"
