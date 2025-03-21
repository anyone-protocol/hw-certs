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
        entrypoint = [ "npx" ]
        args = [ "tsx", "src/update-issuer-names.ts" ]
        mount {
          type = "bind"
          target = "/etc/ssl/certs/vault-ca.crt"
          source = "/opt/nomad/tls/vault-ca.crt"
          readonly = true
          bind_options {
            propagation = "private"
          }
        }
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
        {{with secret "kv/vault"}}
        VAULT_ADDR="{{.Data.data.VAULT_ADDR}}"
        {{end}}
        EOH
        destination = "secrets/env"
        env         = true
      }
    }
  }
}
