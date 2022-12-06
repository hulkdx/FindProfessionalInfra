 resource "aws_eks_cluster" "main_eks" {
   name     = var.cluster_name
   role_arn = aws_iam_role.eks_role.arn
   vpc_config {
     subnet_ids = local.public_subnet_ids
   }
   depends_on = [aws_iam_role_policy_attachment.eks_policy_AmazonEKSClusterPolicy]
 }

 resource "aws_eks_node_group" "main_eks_node_group" {
   cluster_name   = aws_eks_cluster.main_eks.name
   node_role_arn  = aws_iam_role.eks_node_group_role.arn
   subnet_ids     = local.public_subnet_ids
   capacity_type  = "ON_DEMAND"
   instance_types = ["t3.micro"]
   scaling_config {
     desired_size = 1
     max_size     = 1
     min_size     = 0
   }
   update_config {
     max_unavailable = 1
   }
   launch_template {
     name    = aws_launch_template.node_group.name
     version = aws_launch_template.node_group.latest_version
   }
   depends_on = [
     aws_iam_role_policy_attachment.eks_node_policy_AmazonEKSWorkerNodePolicy,
     aws_iam_role_policy_attachment.eks_node_policy_AmazonEC2ContainerRegistryReadOnly,
     aws_iam_role_policy_attachment.eks_node_policy_AmazonEKS_CNI_Policy,
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

 resource "aws_launch_template" "node_group" {
   vpc_security_group_ids = [
     aws_eks_cluster.main_eks.vpc_config[0].cluster_security_group_id,
     aws_security_group.node_group.id,
   ]
   metadata_options {
     http_put_response_hop_limit = 2
     http_tokens                 = "required"
   }
   user_data  = data.cloudinit_config.node_group.rendered
   depends_on = [aws_eks_addon.vpc_cni]
 }

 data "cloudinit_config" "node_group" {
   base64_encode = true
   gzip          = false
   boundary      = "//"
   part {
     content_type = "text/x-shellscript"
     content      = local.increase_max_pods_script
   }
 }

 # -------------------------------------------------------------------------------------
 # Increase max pods
 #	https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/
 # https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
 # -------------------------------------------------------------------------------------
 locals {
   # t3.micro
   max_pods = "32"
 }
 # step 1
 resource "null_resource" "kubectl_set_env" {
   triggers = {
     once = true
   }
   provisioner "local-exec" {
     interpreter = ["/bin/bash", "-c"]
     command     = <<-EOT
       aws eks update-kubeconfig --name ${aws_eks_cluster.main_eks.name}
       kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
     EOT
   }
 }
 # step 2
 resource "aws_eks_addon" "vpc_cni" {
   cluster_name             = aws_eks_cluster.main_eks.name
   addon_name               = "vpc-cni"
   resolve_conflicts        = "OVERWRITE"
   addon_version            = data.aws_eks_addon_version.latest.version
   service_account_role_arn = aws_iam_role.oidc.arn
   depends_on               = [null_resource.kubectl_set_env]
 }
 data "aws_eks_addon_version" "latest" {
   addon_name         = "vpc-cni"
   kubernetes_version = aws_eks_cluster.main_eks.version
   most_recent        = true
 }
 # step 3
 locals {
   increase_max_pods_script = <<-EOF
     !/bin/bash
     set -o xtrace
     /etc/eks/bootstrap.sh ${var.cluster_name} \
       --b64-cluster-ca ${aws_eks_cluster.main_eks.certificate_authority[0].data}
       --apiserver-endpoint ${aws_eks_cluster.main_eks.endpoint}
       --use-max-pods false \
       --kubelet-extra-args '--max-pods=34'
   EOF
 }
