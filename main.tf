# resource "aws_eks_cluster" "main_eks" {
#   name     = var.cluster_name
#   role_arn = aws_iam_role.eks_role.arn
#   vpc_config {
#     subnet_ids = local.public_subnet_ids
#   }
#   depends_on = [aws_iam_role_policy_attachment.eks_policy_AmazonEKSClusterPolicy]
# }

# resource "aws_eks_node_group" "main_eks_node_group" {
#   cluster_name   = aws_eks_cluster.main_eks.name
#   node_role_arn  = aws_iam_role.eks_node_group_role.arn
#   subnet_ids     = local.public_subnet_ids
#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t3.small"]
#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 0
#   }
#   update_config {
#     max_unavailable = 1
#   }
#   launch_template {
#     name    = aws_launch_template.node_group.name
#     version = aws_launch_template.node_group.latest_version
#   }
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_policy_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks_node_policy_AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.eks_node_policy_AmazonEKS_CNI_Policy,
#   ]
# }

# resource "aws_security_group" "node_group" {
#   vpc_id = aws_vpc.main_vpc.id
#   ingress {
#     from_port   = 30000
#     to_port     = 30000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_launch_template" "node_group" {
#   vpc_security_group_ids = [
#     aws_eks_cluster.main_eks.vpc_config[0].cluster_security_group_id,
#     aws_security_group.node_group.id,
#   ]
# }

# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name             = aws_eks_cluster.main_eks.name
#   addon_name               = "vpc-cni"
#   resolve_conflicts        = "OVERWRITE"
#   addon_version            = data.aws_eks_addon_version.latest.version
#   service_account_role_arn = aws_iam_role.oidc.arn
#   configuration_values     = jsonencode({
#     env = {
#       # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
#       ENABLE_PREFIX_DELEGATION = "true"
#       WARM_PREFIX_TARGET       = "1"
#     }
#   })
# }
# data "aws_eks_addon_version" "latest" {
#   addon_name         = "vpc-cni"
#   kubernetes_version = aws_eks_cluster.main_eks.version
#   most_recent        = true
# }
#
# resource "aws_eks_addon" "coredns" {
#   cluster_name             = aws_eks_cluster.main_eks.name
#   addon_name               = "coredns"
# }
# resource "aws_eks_addon" "kube-proxy" {
#   cluster_name             = aws_eks_cluster.main_eks.name
#   addon_name               = "kube-proxy"
# }
