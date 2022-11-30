resource "aws_eks_cluster" "main_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn
  depends_on = [aws_iam_role_policy_attachment.eks_policy_AmazonEKSClusterPolicy]

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
    ]
  }
}

resource "aws_eks_node_group" "main_eks_node_group" {
  cluster_name  = aws_eks_cluster.main_eks.name
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  
  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.micro"]
  disk_size = 4

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEKS_CNI_Policy,
  ]
}

################################################################################
# eks role + policy
################################################################################

resource "aws_iam_role" "eks_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_policy_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

################################################################################
# node group role + policy
################################################################################

resource "aws_iam_role" "eks_node_group_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "eks_node_policy_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}
resource "aws_iam_role_policy_attachment" "eks_node_policy_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}
resource "aws_iam_role_policy_attachment" "eks_node_policy_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

################################################################################
# oidc
################################################################################

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks.url
}

output "oidc_arn" {
  value = aws_iam_role.test_oidc.arn
}
