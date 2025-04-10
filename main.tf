provider aws {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block  = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}


resource "aws_internet_gateway" "myapp_gw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}


resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_gw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id      = aws_vpc.myapp-vpc.id
    
    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks = [var.my-ip,var.subnet_cidr_block]
  }

    ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "ICMP"
    cidr_blocks = [var.subnet_cidr_block]
  }
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
    tags = {
        Name = "${var.env_prefix}-default-sg"
    } 
}


data "aws_ami" "ubuntu-latest-image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-pro-server/images/hvm-ssd/ubuntu-jammy-22.04-amd64-pro-server-20241113"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "my-jump-server" {
  ami = data.aws_ami.ubuntu-latest-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-app-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  user_data_replace_on_change = true


  tags = {
    Name = "${var.env_prefix}-server"
  }
}

resource "aws_instance" "master-node" {
  ami = data.aws_ami.ubuntu-latest-image.id
  instance_type = "t3.small"
  subnet_id = aws_subnet.my-app-subnet.id
  #vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = "pvt-key-pair"

  #user_data = file("entry-script.sh")

  #user_data_replace_on_change = true


  tags = {
    Name = "master-node"
  }
}

resource "aws_instance" "worker-node" {
  ami = data.aws_ami.ubuntu-latest-image.id
  instance_type = "t3.small"
  subnet_id = aws_subnet.my-app-subnet.id
  #vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = "pvt-key-pair"

  #user_data = file("entry-script.sh")

  #user_data_replace_on_change = true


  tags = {
    Name = "worker-node"
  }
}
