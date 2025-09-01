variable "AWS_ECR_PUBLIC_ALIAS" {
  default = "dev1-sg"
}

variable "AWS_ECR_PUBLIC_REGION" {
  default = "us-east-1"
}

variable "AWS_ECR_PUBLIC_URI" {
  default = "public.ecr.aws/dev1-sg"
}

variable "AWS_ECR_PUBLIC_URL" {
  default = "https://ecr-public.us-east-1.amazonaws.com"
}

variable "AWS_ECR_PUBLIC_REPOSITORY_GROUP" {
  default = "base"
}

variable "AWS_ECR_PUBLIC_IMAGE_NAME" {
  default = "node"
}

variable "AWS_ECR_PUBLIC_IMAGE_TAG" {
  default = "24.5.0"
}

variable "AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN" {
  default = "debian"
}

variable "AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU" {
  default = "ubuntu"
}

variable "AWS_ECR_PUBLIC_IMAGE_URI" {
  default = "public.ecr.aws/dev1-sg/base/node:latest"
}

target "metadata" {
  labels = {
    "org.opencontainers.image.title"       = "${AWS_ECR_PUBLIC_IMAGE_NAME}"
    "org.opencontainers.image.description" = "Minimal ${AWS_ECR_PUBLIC_IMAGE_NAME} ${AWS_ECR_PUBLIC_REPOSITORY_GROUP} image for internal use"
    "org.opencontainers.image.url"         = "https://gitlab.com/dev1-sg/public/docker-${AWS_ECR_PUBLIC_REPOSITORY_GROUP}-images/-/tree/main/src/${AWS_ECR_PUBLIC_IMAGE_NAME}"
    "org.opencontainers.image.source"      = "https://gitlab.com/dev1-sg/public/docker-${AWS_ECR_PUBLIC_REPOSITORY_GROUP}-images"
    "org.opencontainers.image.version"     = "${AWS_ECR_PUBLIC_IMAGE_TAG}"
  }
}

target "settings" {
  context = "."
  cache-from = [
    "type=gha"
  ]
  cache-to = [
    "type=gha,mode=max"
  ]
  args = {
    NODE_VERSION = "${AWS_ECR_PUBLIC_IMAGE_TAG}"
  }
}

target "test-debian" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.debian"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = []
}

target "test-ubuntu" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.ubuntu"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = []
}

target "build-debian" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.debian"
  output     = ["type=docker"]
  tags = [
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:latest",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:debian",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}-${AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}",
  ]
}

target "build-ubuntu" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.ubuntu"
  output     = ["type=docker"]
  tags = [
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:ubuntu",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}-${AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU}",
  ]
}

target "push-debian" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.debian"
  output     = ["type=registry"]
  platforms  = ["linux/amd64", "linux/arm64"]
  tags = [
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:latest",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:debian",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}-${AWS_ECR_PUBLIC_IMAGE_TAG_DEBIAN}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}",
  ]
}

target "push-ubuntu" {
  inherits   = ["settings", "metadata"]
  dockerfile = "Dockerfile.ubuntu"
  output     = ["type=registry"]
  platforms  = ["linux/amd64", "linux/arm64"]
  tags = [
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:ubuntu",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU}",
    "${AWS_ECR_PUBLIC_URI}/${AWS_ECR_PUBLIC_REPOSITORY_GROUP}/${AWS_ECR_PUBLIC_IMAGE_NAME}:${AWS_ECR_PUBLIC_IMAGE_TAG}-${AWS_ECR_PUBLIC_IMAGE_TAG_UBUNTU}",
  ]
}

group "default" {
  targets = ["test-debian"]
}

group "test" {
  targets = ["test-debian"]
}

group "build" {
  targets = ["build-debian", "build-ubuntu"]
}

group "push" {
  targets = ["push-debian", "push-ubuntu"]
}
