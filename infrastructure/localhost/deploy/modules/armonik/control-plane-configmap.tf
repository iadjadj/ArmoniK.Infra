# Envvars
locals {
  control_plane_config = <<EOF
{
  "target_data_path": "${var.armonik.storage_services.shared_storage.target_path}",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Grpc": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "*",
  "Kestrel": {
    "EndpointDefaults": {
      "Protocols": "Http2"
    }
  },
  "Serilog": {
    "Using": [ "Serilog.Sinks.Console" ],
    "MinimumLevel": "Information",
    "WriteTo": [
      {
        "Name": "Console",
        "Args": {
          "formatter": "Serilog.Formatting.Compact.CompactJsonFormatter, Serilog.Formatting.Compact"
        }
      },
      {
        "Name": "Seq",
        "Args": {
          "serverUrl": "http://${kubernetes_service.seq_ingestion.spec.0.cluster_ip}:5341"
        }
      }
    ],
    "Enrich": [ "FromLogContext", "WithMachineName", "WithThreadId" ],
    "Destructure": [
      {
        "Name": "ToMaximumDepth",
        "Args": { "maximumDestructuringDepth": 4 }
      },
      {
        "Name": "ToMaximumStringLength",
        "Args": { "maximumStringLength": 100 }
      },
      {
        "Name": "ToMaximumCollectionCount",
        "Args": { "maximumCollectionCount": 10 }
      }
    ],
    "Properties": {
      "Application": "ArmoniK.Control"
    }
  },
  "Components": {
    "TableStorage": "ArmoniK.Adapters.${var.armonik.storage_services.table_storage_type}",
    "QueueStorage": "ArmoniK.Adapters.${var.armonik.storage_services.queue_storage_type}",
    "ObjectStorage": "ArmoniK.Adapters.${var.armonik.storage_services.object_storage_type}",
    "LeaseProvider": "ArmoniK.Adapters.${var.armonik.storage_services.lease_provider_storage_type}"
  },
  "MongoDB": {
    "ConnectionString": "${var.armonik.storage_services.resources.mongodb_endpoint_url}",
    "DatabaseName": "database",
    "DataRetention": "10.00:00:00",
    "TableStorage": {
      "PollingDelay": "00:00:01"
    },
    "LeaseProvider": {
      "AcquisitionPeriod": "00:00:30",
      "AcquisitionDuration": "00:01:00"
    },
    "ObjectStorage": {
      "ChunkSize": "100000"
    },
    "QueueStorage": {
      "LockRefreshPeriodicity": "00:00:45",
      "PollPeriodicity": "00:00:01",
      "LockRefreshExtension": "00:02:00"
    }
  },
  "Amqp" : {
    "Address" : "${var.armonik.storage_services.resources.activemq_endpoint_url}",
    "MaxPriority" : 10,
    "QueueStorage": {
      "LockRefreshPeriodicity": "00:00:45",
      "PollPeriodicity": "00:00:10",
      "LockRefreshExtension": "00:02:00"
    }
  }
}
EOF
}

#configmap with all the variables
resource "kubernetes_config_map" "control_plane_config" {
  metadata {
    name      = "control-plane-configmap"
    namespace = var.namespace
  }
  data = {
    "appsettings.json" = local.control_plane_config
  }
}

resource "local_file" "control_plane_config_file" {
  content  = local.control_plane_config
  filename = "./generated/configmaps/control-plane-appsettings.json"
}