resource "azurerm_mssql_server" "sql_server"{

    name = "sqlserver-bd-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    location = var.location
    version = "12.0"
    administrator_login = "sql_admin"
    administrator_login_password = var.password

    tags = var.tags


}

resource "azurerm_mssql_database" "sql_BD"{
    name = "otd.db"
    server_id = azurerm_mssql_server.sql_server.id
    sku_name = "S0"
    tags = var.tags
} 

resource "azurerm_private_endpoint" "sql_private_endpoint"{

    name = "sql_private_endpoint-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    location = var.location
    subnet_id = azurerm_subnet.subnetBD.id

    private_service_connection {
        name = "sql_private_cn-${var.project}-${var.environment}"
        private_connection_resource_id = azurerm_mssql_server.sql_server.id
        subresource_names = ["SqlServer"]
        is_manual_connection = false
    }

    tags = var.tags
}

resource "azurerm_private_dns_zone" "dns_zone"{
    name = "private.dbserver.database.windows.net"
    resource_group_name = azurerm_resource_group.gr.name

    tags = var.tags
}

resource "azurerm_private_dns_a_record" "dns_a_record"{
    name= "sqlserver-record-${var.project}-${var.environment}"
    zone_name = azurerm_private_dns_zone.dns_zone.name
    resource_group_name = azurerm_resource_group.gr.name
    ttl = 330
    records =[azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]


}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link"{
    name = "vnetlink-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.gr.name
    private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
  name = "allow_my_ip"
  start_ip_address = "201.190.16.157"
  end_ip_address = "201.190.16.157"
  server_id = azurerm_mssql_server.sql_server.id
}