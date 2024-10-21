resource "azurerm_storage_account" "storage_account"{
    name = "storage${var.project}${var.environment}yis"
    resource_group_name = azurerm_resource_group.gr.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"

    tags = var.tags
}

resource "azurerm_storage_container" "blob_dbk_container" {
    name = "dbknowledge"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}

resource "azurerm_storage_container" "blob_dbv_container" {
    name = "dbvectors"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}

resource "azurerm_storage_queue" "storage_queue" {
    name = "vectordb-calibration-request"
    storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_private_endpoint" "blob_private_endpoint"{

    name = "blob-private-endpoint-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    location = var.location
    subnet_id = azurerm_subnet.subnetApp.id

    private_service_connection {
        name = "storage-private-${var.project}-${var.environment}"
        private_connection_resource_id = azurerm_storage_account.storage_account.id
        subresource_names = ["blob"]
        is_manual_connection = false
    }

    tags = var.tags

}

resource "azurerm_private_endpoint" "queue_private_endpoint"{

    name = "queue-private-endpoint-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    location = var.location
    subnet_id = azurerm_subnet.subnetApp.id

    private_service_connection {
        name = "storage-private-${var.project}-${var.environment}"
        private_connection_resource_id = azurerm_storage_account.storage_account.id
        subresource_names = ["queue"]
        is_manual_connection = false
    }

    tags = var.tags

}

resource "azurerm_private_dns_zone" "sa_private_dns_zone"{

    name= "privatelink.storage.core.windows.net"
    resource_group_name = azurerm_resource_group.gr.name

    tags = var.tags

}

resource "azurerm_private_dns_a_record" "sa_private_dns_a_record"{

    name = "storage-record-${var.project}-${var.environment}"
    zone_name = azurerm_private_dns_zone.sa_private_dns_zone.name
    resource_group_name = azurerm_resource_group.gr.name
    ttl = 300
    records = [
        azurerm_private_endpoint.blob_private_endpoint.private_service_connection[0].private_ip_address
        , azurerm_private_endpoint.queue_private_endpoint.private_service_connection[0].private_ip_address
    ]

}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_vnet_link"{
    name = "sa-vnetlink-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    private_dns_zone_name = azurerm_private_dns_zone.sa_private_dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}