locals {
  apigee_service_account= lookup({
    "QA" =["serviceaccount:sa-apipub-cloud-run-qa@prj-apimgnt-qa-psa-qa-8e22.iam.gseviceaccount.com"],
    "DEV"= ["serviceaccount:sa-apipub-cloud-run-qa@prj-apimgnt-qa-psa-qa-8e22.iam.gseviceaccount.com"],
    "QA"= ["serviceaccount:sa-apipub-cloud-run-qa@prj-apimgnt-qa-psa-qa-8e22.iam.gseviceaccount.com"],
    "PROD"= ["serviceaccount:sa-apipub-cloud-run-qa@prj-apimgnt-qa-psa-qa-8e22.iam.gseviceaccount.com"]
  },var.apigee_environment, [])
  str_keys=  length(var.keys) >="1" ? var.keys[0]: ""
  default_key_path = local.str_keys == "" ? var.kms_key_path == "" ? null : var.kms_key_path : var.keyring == "" ? var.kms_key_path == "" ? null : var.kms_key_path : var.kms_key_path == "" ? "${var.keyring}/cryptokeys/${local.str_keys}" : var.kms_key_path
}


resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    spec {

      service_account_name = var.service_account_email
      container_concurrency = var.container_concurrency
      timeout_seconds = var.timeout_seconds
      containers {
        image = var.service_image_url
        ports{
          
          name    =  var.http2 ? "h2c" : "http1"
          container_port = var.port
        }
        resources {
          limits = {
              cpu = "${var.cpu_count * 1000}m"
              memory = "${var.memory_size}M"
          }
                 }
      
    
    
    #standard environment variables
      dynamic "env"{
        for_each = var.environment
        content{
          name = lookup(env.value, "name", null)
          value = lookup(env.value, "value", null)
        }
      }

      #secret environment variables
      dynamic "env"{
        for_each = var.secret_environment
        content{
          name = lookup(env.value, "name", null)
          value_from {
            secret_key_ref{
              name = lookup(env.value, "secret_name", null)
              key = lookup(env.value, "secret_version", null)
            }
          }       
      }
      }
      #secret volume moubts
    dynamic "volume mounts"{
      for_each = var.volume_mounts
      content{
        name = lookup(volume_mounts.value, "volume_name", null)
        mount_path = lookup(volume_mounts.value, "mount_path", null)
      }
    }
      }
      #secret files to mount to volume
      dynamic "volumes"{
        for_each = var.secret_volume
        content{
          name = lookup(volumes.value, "volume_name", null)
          #secret
          secret{
            secret_name = lookup(volumes.value, "secret_id", null)
            #default_mode = 420 # 0644
            items{

              key = lookup(volumes.value, "secret_version", null)
              path = lookup(volumes.value, "secret_path", null)
              mode = lookup(volumes.value, "secret_mode", null)
            }
          }
        }
      }
    }
    # without revision value
    dynamic "metadata"{
      for_each = var.new_revision == "1" ? [1] : []
      content {
        
        annotations = {
       generated-by = "magic-modules"
       "autoscaling.knative.dev/maxscale" = var.max_instance_count
       "autoscaling.knative.dev/minscale" = var. min_instance_count
       "run.googleapis.com/vpc-access-connector" = var.service_vpc_connector
       "run.googleapis.com/vpc-access-egress"   = var.vpc_egress
       "run.googleapis.com/cpu-throtting"       = var.cpu_throtting
       "run.googleapis.com/launch-stage"         = "BETA"
      "run.googleapis.com/ingress-status" = "all"
        "run.googleapis.com/execution-environment" = var.execution_environment
       "run.googleapis.com/encryption-key"  =local.default_key_path

      }
    }
    
    
    }
#with revision value
    dynamic "metadata"{
      for_each = var.new_revision == "1" ? [1] : []
      content {
        name = "${var.service_name}-${var.new_revision}"
        annotations = {
       generated-by = "magic-modules"
       "autoscaling.knative.dev/maxscale" = var.max_instance_count
       "autoscaling.knative.dev/minscale" = var. min_instance_count
       "run.googleapis.com/vpc-access-connector" = var.service_vpc_connector
       "run.googleapis.com/vpc-access-egress"   = var.vpc_egress
       "run.googleapis.com/cpu-throtting"       = var.cpu_throtting
       "run.googleapis.com/launch-stage"         = "BETA"
      "run.googleapis.com/ingress-status" = "all"
        "run.googleapis.com/execution-environment" = var.execution_environment
       "run.googleapis.com/encryption-key"  =local.default_key_path

      }
    }
    
    
    }

  }
  metadata {
    lables = var.lables
    annotations = {
      "run.googleapis.com/ingess" = var.ingress_traffic_type
    }
  }


#without revision value
dynamic "traffic"{
  for_each = var.new_revision == "1" ? [1] : []
  content{
    percent        = 100
    latest_revision = true
    tag             = var.new_revision_tag
  }
}

#with new revision value
dynamic "traffic"{
  for_each = var.new_revision == "1" ? [1] : []
  content{
    percent        = var.traffic_to_new_revision
    revision_name = "${var.service_name}-${var.new_revision}"
    tag             = var.new_revision_tag
  }
}
#with old revision value
dynamic "traffic"{
  for_each = var.new_revision == "1" ? [1] : []
  content{
    percent        = var.traffic_to_old_revision
    revision_name = "${var.service_name}-${var.old_revision}"
    tag             = var.new_revision_tag
  }
}

  
  autogenerate_revision_name = var.new_revision == "1" ? true : false
}

# resource "google_sql_database_instance" "instance" {
#   name             = "cloudrun-sql"
#   region           = "us-east1"
#   database_version = "postgress"
#   settings {
#     tier = "db-f1-micro"
#   }

#   deletion_protection  = "true"
# }
# data "google_iam_policy" "noauth" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       "allUsers",
#     ]
#   }
# }


# resource "google_cloud_run_service_iam_policy" "noauth" {
#   location    = google_cloud_run_service.default.location
#   project     = google_cloud_run_service.default.project
#   service     = google_cloud_run_service.default.name

#   policy_data = data.google_iam_policy.noauth.policy_data
# }
# lifecycle {
#     ignore_changes = [
#       metadata.0.annotations,
#     ]
#   }s

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.default.location
  project  = var.gcp_project_id
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  count = length(concat(var.service_invoker, local.apigee_service_account))
  member   = concat(var.service_invoker, local.apigee_service_account)[count.index]
}
