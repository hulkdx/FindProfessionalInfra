data "tls_certificate" "eks_tls" {
  url = aws_eks_cluster.main_eks.identity[0].oidc[0].issuer
}

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.demo.identity[0].oidc[0].issuer
# }

# ### test 
# resource "aws_iam_role" "test_oidc" {
#   assume_role_policy = jsonencode({
#     Statement = {
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Effect = "Allow"
#       Condition = {
#         Test     = "StringEquals"
#         Variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#         Values   = ["system:serviceaccount:default:aws-test"]
#       }
#       Principal = {
#         Identifiers = [aws_iam_openid_connect_provider.eks.arn]
#         Type        = "Federated"
#       }
#     }
#   })
# }

# data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:default:aws-test"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "test_oidc" {
#   assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
# }

# resource "aws_iam_policy" "test-policy" {
#   name = "test-policy"

#   policy = jsonencode({
#     Statement = [{
#       Action = [
#         "s3:ListAllMyBuckets",
#         "s3:GetBucketLocation"
#       ]
#       Effect   = "Allow"
#       Resource = "arn:aws:s3:::*"
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "test_attach" {
#   role       = aws_iam_role.test_oidc.name
#   policy_arn = aws_iam_policy.test-policy.arn
# }

# output "test_policy_arn" {
#   value = aws_iam_role.test_oidc.arn
# }
