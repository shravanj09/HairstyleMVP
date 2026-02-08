variable "name_prefix" {
  type        = string
  description = "Lowercase name prefix for resources (letters/numbers only)."
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "eastus"
}

variable "container_image" {
  type        = string
  description = "Container image for the API."
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "lightx_api_key" {
  type        = string
  description = "LightX API key."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {
    app = "looks-mvp"
  }
}
