resource "aws_instance" "aws_ec2_instance_control" {
  ami           = var.ami_id
  instance_type = var.instance_type_control
  count         = var.number_of_instances_control

  vpc_security_group_ids = [aws_security_group.aws_rke2_sg.id]
  subnet_id              = element([aws_subnet.aws_rke2_private_subnet1.id], count.index % 1)
  iam_instance_profile   = aws_iam_instance_profile.aws_iam_profile_control.name
  key_name               = var.key_pair_name
  depends_on             = [aws_nat_gateway.aws_rke2_ngw]

  user_data = templatefile("${path.module}/scripts/control-node.sh", {
    DOMAIN = "${var.domain}"
    TOKEN  = "${var.token}"
    vRKE2  = "${var.vRKE2}"
  })

  tags = {
    Name = "${var.prefix}-cp-0${count.index + 1}"
  }

  root_block_device {
    volume_size           = var.volume_size_control
    volume_type           = var.volume_type_control
    encrypted             = var.encrypted
    delete_on_termination = var.delete_on_termination

    tags = {
      Name = "${var.prefix}-cp-volume-0${count.index + 1}"
    }
  }
}

resource "aws_instance" "aws_ec2_instance_worker" {
  ami           = var.ami_id
  instance_type = var.instance_type_worker
  count         = var.number_of_instances_worker

  vpc_security_group_ids = [aws_security_group.aws_rke2_sg.id]
  subnet_id              = element([aws_subnet.aws_rke2_private_subnet1.id, aws_subnet.aws_rke2_private_subnet2.id, aws_subnet.aws_rke2_private_subnet3.id], count.index % 3)
  iam_instance_profile   = aws_iam_instance_profile.aws_iam_profile_worker.name
  key_name               = var.key_pair_name
  depends_on             = [aws_instance.aws_ec2_instance_control]

  user_data = templatefile("${path.module}/scripts/worker-nodes.sh", {
    DOMAIN = "${var.domain}"
    TOKEN  = "${var.token}"
    vRKE2  = "${var.vRKE2}"
  })

  tags = {
    Name = "${var.prefix}-wk-0${count.index + 1}"
  }

  root_block_device {
    volume_size           = var.volume_size_worker
    volume_type           = var.volume_type_worker
    encrypted             = var.encrypted
    delete_on_termination = var.delete_on_termination

    tags = {
      Name = "${var.prefix}-wk-volume-0${count.index + 1}"
    }
  }
}
