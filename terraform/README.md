# Desafio Aquarela - Deploy EKS com Terraform

Este projeto provisiona um cluster EKS gerenciado na AWS utilizando Terraform, com separação de recursos em arquivos para facilitar o entendimento e manutenção.

## Estrutura dos arquivos
- `main.tf`: Providers, variáveis locais e VPC.
- `eks-al2023.tf`: Módulo do EKS.
- `eks-aws-auth.tf`: Configuração do aws-auth para acesso ao cluster.
- `versions.tf`: Versão do Terraform e providers.
- `iam.tf`: Recursos de IAM (usuário e permissões administrativas).

## Passos para o deploy
1. Inicialize o Terraform:
   ```bash
   terraform init
   ```
2. Visualize o plano de execução:
   ```bash
   terraform plan -out=tmp/tmp.plan
   ```
3. Aplique o deploy:
   ```bash
   terraform apply "tpm/tmp.plan"
   ```
4. Após o deploy, o kubeconfig será atualizado para acesso ao cluster EKS.

## Observações
- O usuário IAM criado terá permissões administrativas.
- O arquivo `eks-aws-auth.tf` garante o acesso dos nodes e do usuário ao cluster.
- Os recursos são criados na região definida em `main.tf`.aa
