



variable "webapp_object" {
  type = object({
    AppName  = string
    ObjectId = string
    TenantId = string
  })
}