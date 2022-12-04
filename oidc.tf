# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.main_eks.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
#   url             = data.tls_certificate.eks.url
# }

# output "oidc_arn" {
#   value = aws_iam_role.test_oidc.arn
# }
