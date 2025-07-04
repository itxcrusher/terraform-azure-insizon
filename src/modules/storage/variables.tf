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
    create_cdn         = optional(bool, false)
    location           = optional(string, "centralus")
  })
}
