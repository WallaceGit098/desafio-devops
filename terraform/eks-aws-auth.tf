# eks-aws-auth.tf
# Arquivo para configurar aws-auth no EKS, separado do main.tf

# Pega a conta atual
data "aws_caller_identity" "current" {}

locals {
  node_group_name = split(":", data.aws_eks_node_group.desafio.id)[1]
}

data "aws_eks_node_group" "desafio" {
  depends_on = [
    module.eks_al2023
  ]
  cluster_name    = module.eks_al2023.cluster_name
  node_group_name = local.node_group_name
}
# ConfigMap aws-auth
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
    module.eks_al2023
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-EOT
        - rolearn: ${data.aws_eks_node_group.desafio.node_role_arn}
            username: system:node:{{EC2PrivateDNSName}}
            groups:
                - system:bootstrappers
                - system:nodes
    EOT
    mapUsers = <<-EOT
      - userarn: ${aws_iam_user.desafio_aquarela.arn}
        username: desafio_aquarela
        groups:
          - system:masters
    EOT
  }
}
