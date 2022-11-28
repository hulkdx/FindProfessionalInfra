resource "aws_eks_cluster" "main_eks" {
  name     = "main_eks"
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
  instance_types = ["t3.nano"]
  disk_size      = "4"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
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
