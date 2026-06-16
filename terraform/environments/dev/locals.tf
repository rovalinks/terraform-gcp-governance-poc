locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }

  # environment_tag_map = {
  #   dev  = "tagValues/281481837036535"
  #   test = "tagValues/281476234994622"
  #   uat  = "tagValues/281480390749157"
  #   prod = "tagValues/281477935936563"
  # }

  # owner_tag_map = {
  #   "platform-team"   = "tagValues/281476571583996"
  #   "cloud-team"      = "tagValues/281483093721712"
  #   "security-team"   = "tagValues/281482234993681"
  #   "networking-team" = "tagValues/281483093920970"
  # }

  # application_tag_map = {
  #   payments  = "tagValues/281484425365550"
  #   ecommerce = "tagValues/281477930450232"
  #   crm       = "tagValues/281480322380749"
  #   analytics = "tagValues/281475223519650"
  # }
}