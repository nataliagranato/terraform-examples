terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
      version = "0.18.10"
    }
  }
}

# Create a Cluster
resource "mgc_kubernetes_cluster" "cluster" {
  name                 = "cluster-example"
  enabled_bastion      = false
  version              = "v1.28.5"
  enabled_server_group = false
  description          = "Cluster Example"
  node_pools = [] # You can create a cluster with a node pool, but in this example, we are creating just the cluster.
}

# Set a timer to wait for the cluster to become active before creating node pools.
# We acknowledge that this is not the optimal approach and are working to improve this behavior.
resource "time_sleep" "wait_15_minutes" {
  depends_on = [mgc_kubernetes_cluster.cluster]
  create_duration = "15m"
}

# Create a Nodepool
resource "mgc_kubernetes_nodepool" "gp1_small" {
  depends_on = [time_sleep.wait_15_minutes] # Wait timer
  name       = "apis-2cpu-4gb-20gb"
  cluster_id = mgc_kubernetes_cluster.cluster.id
  flavor     = "cloud-k8s.gp1.small"
  replicas   = 1
  auto_scale = {
    min_replicas = 1
    max_replicas = 3
  }
}


# Create a Cluster with nodepool
resource "mgc_kubernetes_cluster" "cluster_with_nodepool" {
  name                 = "cluster-example"
  enabled_bastion      = false
  version              = "v1.28.5"
  enabled_server_group = false
  description          = "Cluster Example"
  node_pools = [{
    name = "node1"
    replicas = 1
    flavor = "cloud-k8s.gp1.small"
  }] 
}