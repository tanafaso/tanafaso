#!/bin/bash

# Exit script when a command fails
set -e

./mvnw package -Dmaven.test.skip=true

docker build --platform linux/amd64 -t tanafaso .

random_tag=$(printf "randomtag%08d" $((RANDOM%100000000)))

docker tag tanafaso europe-west1-docker.pkg.dev/tanafaso/tanafaso/tanafaso:$random_tag

docker push europe-west1-docker.pkg.dev/tanafaso/tanafaso/tanafaso:$random_tag

sed -i '' "s|image: europe-west1-docker.pkg.dev/tanafaso/tanafaso/tanafaso:.*|image: europe-west1-docker.pkg.dev/tanafaso/tanafaso/tanafaso:$random_tag|" tanafaso-cloud-run-service.yaml

gcloud run services replace tanafaso-cloud-run-service.yaml --region europe-west1

echo "Deployed with tag: $random_tag"

