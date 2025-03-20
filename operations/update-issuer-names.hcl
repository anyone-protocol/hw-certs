job "update-issuer-names" {
  datacenters = ["ator-fin"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  group "update-issuer-names-group" {
    count = 1

    network {
      mode = "bridge"
    }

    task "update-issuer-names-task" {
      driver = "docker"
      config {
        image = "ghcr.io/anyone-protocol/hw-certs:latest"
        force_pull = true
        volumes = [
          "local/vault-ca.crt:/etc/ssl/certs/vault-ca.crt"
        ]
      }

      resources {
        cpu    = 4096
        memory = 4096
      }

      restart {
        attempts = 0
        mode = "fail"
      }

      env {
        BUMP="bipbump2"
      }

      vault {
        policies = ["pki-hardware-admin-worker"]
      }

      template {
        data = <<-EOH
        VAULT_ADDR="TODO"
        EOH
        destination = "secrets/env"
        env         = true
      }

      template {
        data = <<-EOH
        EOH
        destination = "local/vault-ca.crt"
      }
    }
  }
}
