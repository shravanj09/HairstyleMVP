variable "name_prefix" {
  type        = string
  description = "Lowercase name prefix for resources (letters/numbers only)."
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "eastus"
}

variable "python_version" {
  type        = string
  description = "Python version for App Service."
  default     = "3.11"
}

variable "app_service_sku" {
  type        = string
  description = "App Service plan SKU (e.g., B1)."
  default     = "B1"
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
