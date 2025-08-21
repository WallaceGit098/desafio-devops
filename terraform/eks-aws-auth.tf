# eks-aws-auth.tf
# Arquivo para configurar aws-auth no EKS, separado do main.tf

# Pega a conta atual
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = module.eks_al2023.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks_al2023.cluster_name
}

data "aws_eks_node_group" "desafio" {
  depends_on = [
    module.eks_al2023
  ]
  cluster_name    = module.eks_al2023.cluster_name
  node_group_name = split(":", module.eks_al2023.eks_managed_node_groups["example"].node_group_id)[length(split(":", module.eks_al2023.eks_managed_node_groups["example"].node_group_id))-1]
}
# ConfigMap aws-auth
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
    null_resource.kubeconfig
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
