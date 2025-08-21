# eks-aws-auth.tf
# Arquivo para configurar aws-auth no EKS, separado do main.tf

# Pega a conta atual
data "aws_caller_identity" "current" {}

data "aws_eks_node_group" "desafio" {
  cluster_name    = module.eks_al2023.cluster_name
  node_group_name = "${local.name}-ng"
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
