# Create the IAM role for the EKS Node Group instances
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to the role (AmazonEKSWorkerNodePolicy is essential)
resource "aws_iam_role_policy_attachment" "eks_node_group_role_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# Create the EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "eks-node-group"
  subnet_ids = [aws_subnet.public.id,aws_subnet.private.id ]
  node_role_arn = aws_iam_role.eks_node_group_role.arn

  scaling_config {
    desired_size = 1
    min_size = 1
    max_size = 1
  }

  instance_types = ["t3.medium"]
  
  disk_size = 20
  
  tags = {
    Name = "eks-node-group"    
  }
}
