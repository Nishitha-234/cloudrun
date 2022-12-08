variable "gcp_project_id" {
    type = string
    description = "the id of the project where the cloud run deployed"
    # validation{
    #     condition = can(regex("^[a-z0-9]+$", var.gcp_project_id))
    #     error_message = "the project name must contain only lowercase letters nmebers and hypens"

    # }

}

variable "service_name"{
    type = string
    description = "the name of the cloud run service"
    validation {
      condition =(
          can(regex("^[a-z)$|^[a-z][a-z0-9-]*[a-z0-9]$", var.service_name))  &&
          length(var.service_name) >= 1 &&
          length(var.service_name) <= 63
      )
      error_message = "The service name must start with a lowercase leter, be between 1-63 characters and contain only lowercase letters, numbers, and hyphens"
    }
}
variable "old_revision" {
    type = string
    description = "For use with traffic splitting on e revision tagging-old version name should not be used in first deployment"
    default = "1"
    validation {
         condition = (
            can(regex("^[a-z0-9-]*[a-z0-9]$", var.old_revision))
            ) || contains(["1"],  var.old_revision)
            
            error_message ="the revision name must be start with a lower case letter and conatains only lower case letter numbers, and hypens"
        }
    }


variable "new_revision" {
    type = string
    description = "For use with traffic splitting on e revision tagging-new version name should not be used in first deployment"
    default = "1"
    validation{
        condition = (
            can(regex("^[a-z0-9-]*[a-z0-9]$", var.new_revision))
            ) || contains(["1"], var.new_revision)
            error_message ="the revision name must be start with a lower case letter and conatains only lower case letter numbers, and hypens"
        }
    }


variable "traffic_to_old_revision"{
    type = number
    description ="for use with traffic splitting and revision tagging - percentag eof traffic to old version.should not be used in firdt deployment"
    default ="0"
}

variable "traffic_to_new_revision"{
    type = number
    description ="for use with traffic splitting and revision tagging - percentag eof traffic to new version"
    default ="0"
}

variable "old_revision_tag"{
type = string
description = "for use  with traffic splitiing and revision tagging - used to expose a dedicated url for referencing the old version .should not be used in first deployment"
default =  ""
validation  {
    condition = can(regex("^[a-z][a-z0-9-]+[a-z0-9]$", var.old_revision_tag)) || contains([""], var.old_revision_tag)
    error_message ="the tag must start with alowercase letter, be at laest 3 characters and contain only lowercase letters, numbers, and hyoens."
}
}

variable "new_revision_tag"{
type = string
description = "for use  with traffic splitiing and revision tagging - used to expose a dedicated url for referencing the new revision ."
default =  ""
validation  {
    condition = can(regex("^[a-z][a-z0-9-]+[a-z0-9]$", var.new_revision_tag)) || contains([""], var.new_revision_tag)
    error_message ="the tag must start with alowercase letter, be at laest 3 characters and contain only lowercase letters, numbers, and hyoens."
}
}

variable "min_instance_count" {
    type = number
    description = "Minimun number of cloud run instances"
    default ="0"

}

variable "max_instance_count" {
    type = number
    description = "Maximum number of cloud run instances - a value over 100 requires a quota increase :https://cloud.google.com/run/quota#how_to_increase_quota_2"
    default ="100"

}

variable "gcp_region"{
    type = string
    description = "the location where the services to be deployed . valod options are us-central1 and us-east4"
    default = "us-central1"
    validation{
        condition = contains(["us-central1", "us-east-4","asia-south1","asia-south2","asia-southeast1","europe-west2","europe-west3"],var.gcp_region)
        error_message =  "incorrect gcp region value"

    }
}

variable "service_image_url"{
    type = string
    description = "the url of image with which the service has to be created"
    validation{
        condition = (
            length(var.service_image_url) > 5 &&
            (can(regex("gcr\\.io", var.service_image_url)) || 
            can(regex("docker\\.pkg\\.dev", var.service_image_url)))
            )
            error_message = "The url must be from the googles registry"
        }
       
    }

variable "service_vpc_connector" {
type = string
description = "vpc network connector"


}
variable "service_account_email"{
    type = string
    description = ""
}
variable "service_invoker"{
    type = list(any)
    description = "accounts that access"
    default = []
}
variable "ingress_traffic_type"{
    type = string
    description = "ingress traffic"
    default = "internal"
    validation{
        condition = var.ingress_traffic_type == "internal"  || var.ingress_traffic_type == "internal-and-cloud-load-balancing" || var.ingress_traffic_type == "all"
       error_message = "incorrect ingress value"
    }
}
variable "container_concurrency"{
    type = number
    description = "maximum number"
    default = "80"
    validation {
        condition = (
            var.container_concurrency >= 1 &&
            var.container_concurrency <= 1000
        )
        error_message = "integer bwtween "
    }
}

variable "timeout_seconds"{
    type = number
    description = ""
    default   = "300"
    validation {
        condition = (
            var.timeout_seconds >= 1 &&
            var.timeout_seconds <= 3600
          )  
          error_message = ""
        }
    }
variable "container_port"{
    type = number
    description =""
    default ="8080"
    validation{
        condition = (
            var.container_port >=1 &&
            var.container_port <= 65535
        )

        error_message =""
    }
}

variable http2 {
  type = bool
  default = false
  description = "Enable use of HTTP/2 end-to-end."
}

variable "cpu_count"{
    type = number
    description = ""
    default = "1"
    validation {
        condition = (var.cpu_count >= 0.08 &&  var.cpu_count <=1) || (var.cpu_count == 2 || var.cpu_count == 4)
        error_message = ""

    }
}

variable "memory_size"{
    type = number
    description = ""
    default = "537"
    validation {
        condition = (
            var.memory_size >= 135 &&
            var.memory_size <= 171719
        )
        error_message = ""
    }
}


variable "environment"{
    description =  ""
    type = list(object({
        name = string
        value = string
    }))
     
     default = []
}

variable "secret_environment"{
    description = ""
    type = list(object({
        name = string
        secret_name = string
        secret_version = string
    }))

    default = []
}

variable "volume_mounts"{
    description ="volume to mount"
    type = list(object({
        volume_name = string
        mount_path  = string
    }))
    default = []
}
variable "secret_volume"{
    description = "secret volume"
    type = list(object({
        volume_name = string
        secret_id = string
        secret_version = string
        secret_path = string
        secret_mode = number
    }))
    default = []
}
variable "cpu_throtting"{
    description = "cpu allocation type"
    type = bool
    default = true
}
variable "apigee_environment"{
    description = "Apigee environment"
    type = string
    default = ""
    validation {
        condition = contains(["QA","DEV","STAGE","PERF","PROD", ""], var.apigee_environment)
        error_message = "allowed values for vpc_egress"
    }
}
variable "vpc_egress"{
    description = ""
    type = string
    default = "all-traffic"
    validation {
        condition = contains(["all-traffic","private-ranges-only"], var.vpc_egress)
        error_message = ""
    }
}
variable "execution_environment"{
    description = ""
    type = string
    default = "gen1"
    validation {
        condition = contains(["gen1","gen2"], var.execution_environment)
        error_message = ""
    }
}
variable "keyring"{
    description = ""
    type = string
    default = ""
}
# variable "keys"{
#     description = ""
#     type = list(string)
#     default = ""
#     validation {
#         condition = length(var.keys) == 1 || length(var.keys) == 0
#         error_message = ""
#     }
# }

variable  "kms_key_path" {
    description = ""
    type = string
    default = ""
}

# variable "cpu boost"{
#     type = bool
# }

# variable "labels" {
#     description = ""
#     type = map(string)
#     default = []
# }