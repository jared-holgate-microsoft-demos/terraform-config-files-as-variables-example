variable "config_file_type" {
  type        = string
  description = "The type of config file, can be json, yaml or both"
  default     = "both"
  validation {
    condition     = contains(["json", "yaml", "both"], var.config_file_type)
    error_message = "config_file_type must be either json, yaml or both"
  }
}

variable "config_file_folder_path" {
  type        = string
  description = "The path to the config files"
  default     = "./config"
}