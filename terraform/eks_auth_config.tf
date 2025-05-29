resource "kubernetes_config_map_v1_data" "aws_auth_users" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        [
          {
            rolearn  = aws_iam_role.jenkins.arn
            username = "jenkins"
            groups   = ["system:masters"]
          }
        ]
      )
    )
  }

  depends_on = [
    module.eks
  ]
  
  # Add force to resolve the field manager conflict
  force = true
}