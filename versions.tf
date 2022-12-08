terraform {
  required_version = ">= 0.13"
}

provider "google" {
  credentials = file("C:/Users/nishi/Downloads/gcp-provisioning.json")  
  region      = "us-west1"
}