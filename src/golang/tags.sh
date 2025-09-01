#!/usr/bin/env bash

set -e

ubuntu=$(sed -n 's/^FROM .*:\([a-zA-Z]*\).*/\1/p' Dockerfile.ubuntu | head -1)
debian=$(sed -n 's/^FROM .*:\([a-zA-Z]*\).*/\1/p' Dockerfile.debian | head -1)
golang=$(cat .go-version)

if [ -z "$ubuntu" ] || [ -z "$debian" ] || [ -z "$golang" ]; then exit 1; fi

export AWS_ECR_PUBLIC_IMAGE_TAG="${golang}"
export AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN="${debian}"
export AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU="${ubuntu}"

if [ -n "$GITHUB_ENV" ]; then
  echo "AWS_ECR_PUBLIC_IMAGE_TAG=$AWS_ECR_PUBLIC_IMAGE_TAG" >> $GITHUB_ENV
  echo "AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN=$AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN" >> $GITHUB_ENV
  echo "AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU=$AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU" >> $GITHUB_ENV
else
  echo "AWS_ECR_PUBLIC_IMAGE_TAG=$AWS_ECR_PUBLIC_IMAGE_TAG"
  echo "AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN=$AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN"
  echo "AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU=$AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU"
fi
