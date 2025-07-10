# ─────────────────────────────────────────────────────────────
#  STORAGE MODULE INPUT
#  Driven 100 % from YAML → Root → Modules
# ─────────────────────────────────────────────────────────────
variable "file_object" {
  description = "One static-file publication job"
  type = object({
    FolderName         = string
    StorageAccountName = string
    ContainerName      = string
    FilesExcluded      = optional(list(string), [])

    # Optional flags
    create_cdn = optional(bool, false)
    location   = optional(string, "centralus")
    custom_domain  = optional(string)   # e.g. "static.insizon.com"
  })
}

variable "enable_static_website" {
  description = "Whether to enable the static website feature for direct access"
  type        = bool
  default     = false
}

variable "static_website_index" {
  description = "Optional override for static website index document"
  type        = string
  default     = null
}

variable "error_404_document" {
  description = "Optional override for static website 404 error document"
  type        = string
  default     = null
}
