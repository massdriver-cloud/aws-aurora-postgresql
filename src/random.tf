resource "random_pet" "root_username" {
  separator = ""
}

resource "random_password" "root_password" {
  length      = 16
  lower       = true
  number      = true
  special     = false
  upper       = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

resource "random_id" "snapshot_identifier" {
  byte_length = 4
}
