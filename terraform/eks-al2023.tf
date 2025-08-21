module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  endpoint_public_access = true
  name               = "${local.name}"
  kubernetes_version = "1.33"

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      name = "${local.name}-ng"
      instance_types = ["t3.small"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size = 1
      max_size = 3
      desired_size = 2
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
          EOT
        }
      ]
    }
  }

  access_entries = {
    wallace_admin = {
      principal_arn = "arn:aws:iam::833565098889:user/wallaces098@hotmail.com"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
  tags = local.tags
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-2 --name ${module.eks_al2023.cluster_id} --kubeconfig .kubeconfig"
  }
  depends_on = [module.eks_al2023]
}

resource "null_resource" "import_aws_auth" {
  provisioner "local-exec" {
    command = <<EOT
      export KUBECONFIG=${path.module}/.kubeconfig
      if kubectl get configmap aws-auth -n kube-system; then
        terraform import kubernetes_config_map.aws_auth kube-system/aws-auth || true
      fi
    EOT
  }

  depends_on = [
    null_resource.kubeconfig,
    module.eks_al2023
  ]
}
