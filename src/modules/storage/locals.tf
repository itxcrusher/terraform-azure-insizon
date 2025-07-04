locals {
  # SA names: 3-24 chars, lowercase letters & digits only, globally unique.
  sa_root          = lower(replace(var.file_object.StorageAccountName, "/[^0-9a-z]/", ""))
  sa_name          = substr("${local.sa_root}${random_string.suffix.result}", 0, 24)

  rg_name          = "${local.sa_name}-rg"
  container_name   = replace(var.file_object.ContainerName, "_", "-")

  src_folder       = abspath("${path.root}/static/${var.file_object.FolderName}")

  include_files = [
    for f in fileset(local.src_folder, "**") :
    f if !contains(var.file_object.FilesExcluded, f)
  ]

  tags = {
    Module    = "storage"
    Folder    = var.file_object.FolderName
    ManagedBy = "Terraform"
  }
}

resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}
