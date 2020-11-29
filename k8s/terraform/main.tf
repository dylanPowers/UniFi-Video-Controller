resource "kubernetes_stateful_set" "unifi_video_controller" {
  metadata {
    name = "unifi-video-controller"
    namespace = var.namespace
  }

  spec {
    replicas = 1
    service_name = "unifi-video-controller"

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }

    selector {
      match_labels = {
        app = "unifi-video-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "unifi-video-controller"
        }
      }

      spec {
        container {
          name = "unifi-video-controller"
          image = "${var.image_registry}/${var.image_name}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : "IfNotPresent"

          env {
            name = "TZ"
            value = "America/Los_Angeles"
          }
          env {
            name = "DEBUG"
            value = var.debug ? "1" : "0"
          }
          env {
            name = "CREATE_TMPFS"
            value = "no"
          }

          security_context {
            privileged = true
            capabilities {
              add = ["DAC_READ_SEARCH"]
            }
          }

          port {
            name = "rtmp"
            container_port = 1935
            protocol = "TCP"
          }
          port {
            name = "camera-streams"
            container_port = 6666
            protocol = "TCP"
          }
          port {
            name = "talkback"
            container_port = 7004
            protocol = "TCP"
          }
          port {
            name = "http-gui"
            container_port = 7080
            protocol = "TCP"
          }
          port {
            name = "camera-mgmt"
            container_port = 7442
            protocol = "TCP"
          }
          port {
            name = "https-gui"
            container_port = 7443
            protocol = "TCP"
          }
          port {
            name = "rtmps"
            container_port = 7444
            protocol = "TCP"
          }
          port {
            name = "http-video"
            container_port = 7445
            protocol = "TCP"
          }
          port {
            name = "https-video"
            container_port = 7446
            protocol = "TCP"
          }
          port {
            name = "rtsp"
            container_port = 7447
            protocol = "TCP"
          }

          volume_mount {
            name = "data-root"
            mount_path = "/var/lib/unifi-video"
          }

          volume_mount {
            name = "videos"
            mount_path = "/mnt/videos"
          }

          volume_mount {
            name = "cache"
            mount_path = "/var/cache/unifi-video"
          }
        }

        volume {
          name = "data-root"
          persistent_volume_claim {
            claim_name = "unifi-video-controller-data-root"
          }
        }

        volume {
          name = "videos"
          persistent_volume_claim {
            claim_name = "unifi-video-controller-videos"
          }
        }

        volume {
          name = "cache"
          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "data_root" {
  metadata {
    name = "unifi-video-controller-data-root"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = ""
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "videos" {
  metadata {
    name = "unifi-video-controller-videos"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = ""
    resources {
      requests = {
        storage = "1Ti"
      }
    }
  }
}

resource "kubernetes_service" "unifi_video_controller" {
  metadata {
    name = "unifi-video-controller"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app" = "unifi-video-controller"
    }

    type = "ClusterIP"


    port {
      name = "rtmp"
      port = 1935
      protocol = "TCP"
      target_port = "rtmp"
    }
    port {
      name = "camera-streams"
      port = 6666
      protocol = "TCP"
      target_port = "camera-streams"
    }
    port {
      name = "talkback"
      port = 7004
      protocol = "TCP"
      target_port = "talkback"
    }
    port {
      name = "http-gui"
      port = 7080
      protocol = "TCP"
      target_port = "http-gui"
    }
    port {
      name = "camera-mgmt"
      port = 7442
      protocol = "TCP"
      target_port = "camera-mgmt"
    }
    port {
      name = "https-gui-default"
      port = 7443
      protocol = "TCP"
      target_port = "https-gui"
    }
    port {
      name = "https-gui"
      port = 443
      protocol = "TCP"
      target_port = "https-gui"
    }
    port {
      name = "rtmps"
      port = 7444
      protocol = "TCP"
      target_port = "rtmps"

    }
    port {
      name = "http-video"
      port = 7445
      protocol = "TCP"
      target_port = "http-video"
    }
    port {
      name = "https-video"
      port = 7446
      protocol = "TCP"
      target_port = "https-video"

    }
    port {
      name = "rtsp"
      port = 7447
      protocol = "TCP"
      target_port = "rtsp"
    }
  }
}
