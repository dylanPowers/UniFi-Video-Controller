variable "image_registry" {
  type = string
  description = "Registry where the Unifi Video Controller image is located"
}

variable "image_name" {
  default = "unifi-video-controller"
  description = "Name of the Unifi Video Controller server image"
}

variable "image_tag" {
  default = "3.10.13-0"
  type = string
  description = "Unifi Video Controller image tag to use"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to install into"
}

variable "debug" {
  default = false
  type = bool
  description = "Enables debug logging and sets the pull policy to Always"
}
