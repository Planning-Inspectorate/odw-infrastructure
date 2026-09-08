# =============================================================================
# SAP BTP Landing Zone - Networking bridge (THEODW-3385 / THEODW-3062)
#
# Exposes the SAP landing storage account (workload-sap-btp.tf) to the SAP BTP
# tenant via a Private Link Service alias. Design:
#
#   SAP BTP  -->  PLS alias  -->  Standard ILB (443)  -->  NGINX VMSS  --TLS-->
#     storage account private endpoint (blob).
#
# The proxy VMSS runs NGINX in TCP passthrough mode (stream module) so BTP
# validates the storage account's native TLS certificate directly (4a - meets
# security requirement R4.01, no cert management on the proxy).
#
# The subnet `SapPlsSubnet` is provisioned via modules/synapse-network (see
# terraform.tfvars) with `private_link_service_network_policies_enabled = false`
# as required for a PLS NAT config.
# =============================================================================

locals {
  sap_pls_deploy   = var.deploy_sap_btp_landing
  sap_pls_subnet   = try(module.synapse_network.vnet_subnets[local.sap_pls_subnet_name], null)
  sap_storage_fqdn = var.deploy_sap_btp_landing ? "${module.storage_account_sap_landing[0].storage_name}.blob.core.windows.net" : ""

  sap_proxy_cloud_init = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y nginx libnginx-mod-stream ca-certificates

    # Replace the default HTTP-only config with a stream (L4) TCP passthrough
    # to the storage account private endpoint. BTP terminates TLS against the
    # storage account's own certificate; NGINX only shuttles bytes.
    cat > /etc/nginx/nginx.conf <<'NGINX'
    user www-data;
    worker_processes auto;
    pid /run/nginx.pid;
    events { worker_connections 4096; }

    stream {
      resolver 168.63.129.16 valid=30s ipv6=off;
      upstream sap_storage_backend {
        server ${local.sap_storage_fqdn}:443;
      }
      server {
        listen 443;
        proxy_pass sap_storage_backend;
        proxy_timeout 300s;
        proxy_connect_timeout 10s;
      }
    }
    NGINX

    systemctl enable nginx
    systemctl restart nginx
    EOT
  )
}

# -----------------------------------------------------------------------------
# NSG for the PLS/proxy subnet
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "sap_pls" {
  count = local.sap_pls_deploy ? 1 : 0

  name                = "pins-nsg-sap-pls-${var.environment}-${module.azure_region.location_short}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  # Azure LB health probes originate from AzureLoadBalancer service tag.
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # PLS forwards client traffic from the LB frontend inside the VNet.
  security_rule {
    name                       = "AllowVnetInbound443"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllOtherInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound to storage PE (resolved via private DNS zone) and Azure metadata.
  security_rule {
    name                       = "AllowStorageOutbound443"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage.UKSouth"
  }

  security_rule {
    name                       = "AllowInternetOutboundForBootstrap"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "sap_pls" {
  count = local.sap_pls_deploy ? 1 : 0

  subnet_id                 = local.sap_pls_subnet
  network_security_group_id = azurerm_network_security_group.sap_pls[0].id
}

# -----------------------------------------------------------------------------
# SSH key material for the proxy VMSS (surfaced in Key Vault for ops recovery)
# -----------------------------------------------------------------------------
resource "tls_private_key" "sap_proxy" {
  count = local.sap_pls_deploy ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "sap_proxy_ssh_private_key" {
  count = local.sap_pls_deploy ? 1 : 0

  name         = "SapProxy-SshPrivateKey"
  content_type = "text/plain"
  key_vault_id = module.synapse_data_lake.key_vault_id
  value        = tls_private_key.sap_proxy[0].private_key_pem
}

# -----------------------------------------------------------------------------
# Standard Internal Load Balancer
# -----------------------------------------------------------------------------
resource "azurerm_lb" "sap" {
  count = local.sap_pls_deploy ? 1 : 0

  name                = "pins-lb-sap-btp-${var.environment}-${module.azure_region.location_short}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "sap-btp-frontend"
    subnet_id                     = local.sap_pls_subnet
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "sap" {
  count = local.sap_pls_deploy ? 1 : 0

  name            = "sap-btp-backend"
  loadbalancer_id = azurerm_lb.sap[0].id
}

resource "azurerm_lb_probe" "sap" {
  count = local.sap_pls_deploy ? 1 : 0

  name                = "sap-btp-tcp-443"
  loadbalancer_id     = azurerm_lb.sap[0].id
  protocol            = "Tcp"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "sap" {
  count = local.sap_pls_deploy ? 1 : 0

  name                           = "sap-btp-tcp-443"
  loadbalancer_id                = azurerm_lb.sap[0].id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.sap[0].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.sap[0].id]
  probe_id                       = azurerm_lb_probe.sap[0].id
  enable_floating_ip             = false
  enable_tcp_reset               = true
  disable_outbound_snat          = true
  idle_timeout_in_minutes        = 15
}

# -----------------------------------------------------------------------------
# Proxy VMSS (Ubuntu 22.04 + NGINX stream module, TCP 443 passthrough)
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "sap_proxy" {
  count = local.sap_pls_deploy ? 1 : 0

  name                = "pins-vmss-sap-proxy-${var.environment}-${module.azure_region.location_short}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  sku                 = var.sap_proxy_vm_sku
  instances           = var.sap_proxy_instance_count

  admin_username                  = var.sap_proxy_admin_username
  disable_password_authentication = true
  upgrade_mode                    = "Automatic"
  custom_data                     = local.sap_proxy_cloud_init

  admin_ssh_key {
    username   = var.sap_proxy_admin_username
    public_key = tls_private_key.sap_proxy[0].public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "sap-proxy-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = local.sap_pls_subnet
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.sap[0].id]
    }
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }

  tags = merge(local.tags, {
    Project = "SAP-BTP-PoC"
  })

  depends_on = [
    azurerm_subnet_network_security_group_association.sap_pls,
    azurerm_private_endpoint.sap_landing_blob_endpoint
  ]
}

# -----------------------------------------------------------------------------
# Private Link Service - alias handed to the SAP/MHCLG team
# -----------------------------------------------------------------------------
resource "azurerm_private_link_service" "sap" {
  count = local.sap_pls_deploy ? 1 : 0

  name                = "pins-pls-sap-btp-${var.environment}-${module.azure_region.location_short}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.sap[0].frontend_ip_configuration[0].id
  ]

  nat_ip_configuration {
    name                       = "primary"
    primary                    = true
    subnet_id                  = local.sap_pls_subnet
    private_ip_address_version = "IPv4"
  }

  # Restricts which subscriptions can see and consume the alias.
  visibility_subscription_ids    = var.sap_btp_approved_subscription_ids
  auto_approval_subscription_ids = var.sap_btp_approved_subscription_ids

  tags = merge(local.tags, {
    Project = "SAP-BTP-PoC"
  })

  depends_on = [azurerm_lb_rule.sap]
}

