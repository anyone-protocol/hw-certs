job "import-hw-signer-certs" {
  datacenters = ["ator-fin"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  group "import-hw-signer-certs-group" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "import-hw-signer-certs" {
      type      = "host"
      read_only = true
      source    = "import-hw-signer-certs"
    }

    task "import-hw-signer-certs-task" {
      driver = "docker"
      config {
        image = "curlimages/curl:8.12.1"
        args = [
          "--header", "X-Vault-Token: ${VAULT_TOKEN}",
          "--verbose",
          "--cacert", "/etc/ssl/certs/vault-ca.crt",
          "--request", "POST",
          "--header", "Content-Type: application/json",
          "-d@/certs/certs.json",
          "${VAULT_ADDR}/v1/pki_hardware/intermediate/set-signed"
        ]
        volumes = [
          "local/vault-ca.crt:/etc/ssl/certs/vault-ca.crt"
        ]
      }

      volume_mount {
        volume      = "import-hw-signer-certs"
        destination = "/certs"
        read_only   = true
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
