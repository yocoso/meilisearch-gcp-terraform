
variable "project_id" {
  description = "your-project-id"
  type        = string
}

variable "region" {
  default     = "us-central1"
  description = "Region to deploy to"
}

variable "zone" {
  default     = "us-central1-a"
  description = "Zone to deploy to"
}
