# now in infrastructure-agents folder

removed {
  from = module.devops_agent_pool
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.devops_agent_pool_failover
  lifecycle {
    destroy = false
  }
}