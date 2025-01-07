resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = jsonencode([
      {
        rolearn  = "arn:aws:iam::713881795316:role/dev-jurist-blueops-nodegroup-role"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
    mapUsers = jsonencode([
      {
        "userarn" : "arn:aws:iam::713881795316:root",
        "username": "root",
        "groups"  : ["system:masters"]
      }
    ])
  }
  
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
}

# resource "kubernetes_cluster_role_binding" "eks_admin" {
#   metadata {
#     name = "eks-admin"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }

#   subject {
#     kind      = "User"
#     name      = "admin-user"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }

# resource "null_resource" "cluster-auth-apply" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region} --alias ${var.cluster_name}"
#   }
# depends_on = [ aws_eks_cluster.eks ]
# }