#  data "tls_certificate" "eks" {
#    url = aws_eks_cluster.main_eks.identity[0].oidc[0].issuer
#  }
#
#  resource "aws_iam_openid_connect_provider" "eks" {
#    client_id_list  = ["sts.amazonaws.com"]
#    thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
#    url             = data.tls_certificate.eks.url
#  }
#
#  data "aws_iam_policy_document" "oidc" {
#    statement {
#      actions = ["sts:AssumeRoleWithWebIdentity"]
#      effect  = "Allow"
#
#      condition {
#        test     = "StringEquals"
#        variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#        values   = ["system:serviceaccount:kube-system:aws-node"]
#      }
#
#      principals {
#        identifiers = [aws_iam_openid_connect_provider.eks.arn]
#        type        = "Federated"
#      }
#    }
#  }
#
#  resource "aws_iam_role" "oidc" {
#    assume_role_policy = data.aws_iam_policy_document.oidc.json
#  }
#
#  resource "aws_iam_role_policy_attachment" "oidc" {
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#    role       = aws_iam_role.oidc.name
#  }
#
#  output "oidc_arn" {
#    value = aws_iam_openid_connect_provider.eks.arn
#  }
