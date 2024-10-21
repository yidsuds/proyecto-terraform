provider "azurerm" {
  features {}

  subscription_id = "fb6d7531-76c4-41d8-95e9-4bc10938e46a"
  tenant_id = "33a93990-8bb4-4b9d-b422-4f8851217d7e"
}

resource "azurerm_resource_group" "gr" {
  name     = "gr-${var.project}-${var.environment}"
  location = var.location

  tags = var.tags
}
