variable "REGISTRY" {
  default = "ghcr.io/freeze060"
}

variable "IMAGE" {
  default = "devsecops-tp1"
}

variable "VERSION" {
  default = "0.0.0-dev"
}

group "default" {
  targets = ["api"]
}

target "api" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = ["${REGISTRY}/${IMAGE}:${VERSION}"]
  secret     = ["id=pip_token,src=secrets/pip_token.txt"]
  cache-from = ["type=registry,ref=${REGISTRY}/${IMAGE}:buildcache"]
  cache-to   = ["type=registry,ref=${REGISTRY}/${IMAGE}:buildcache,mode=max"]
}
