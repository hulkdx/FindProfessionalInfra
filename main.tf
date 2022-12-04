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
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    name = aws_launch_template.node_group.name
    version = aws_launch_template.node_group.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_policy_AmazonEKS_CNI_Policy,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "node_group" {
  vpc_security_group_ids = [
    aws_eks_cluster.main_eks.vpc_config[0].cluster_security_group_id,
    aws_security_group.node_group.id,
  ]
}

resource "aws_security_group" "node_group" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}