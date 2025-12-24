############################################
# IAM for EC2
############################################

resource "aws_iam_role" "ec2" {
  name = "${var.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

############################################
# Launch Template
############################################

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
dnf update -y
dnf install -y httpd
echo "<h1>Healthy from $(hostname)</h1>" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-app"
    }
  }
}

############################################
# Auto Scaling Group
############################################

resource "aws_autoscaling_group" "this" {
  name             = "${var.name}-asg"
  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = true
  }
}
