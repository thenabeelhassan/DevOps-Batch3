resource "aws_instance" "ec2_instance" {
    ami                    = "ami-0bdb4b5c0e2417d4f"  # Ubuntu 22.04 AMI (Check latest in your region)
    instance_type          = "t3.micro"  # Change as needed
    key_name               = "DevOpsB3-Keypair"  # Replace with your actual key pair
    associate_public_ip_address = true
    subnet_id              = "subnet-08278f0f1eee4462c"  # Replace with your subnet ID
    vpc_security_group_ids = [ "sg-0587cfd551e03261c" ]

    iam_instance_profile   = "EC2-Access-ECR"

    user_data = <<-EOF
            #!/bin/bash

            apt-get update
            apt-get upgrade -y

            for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do  apt-get remove $pkg; done

            # Add Docker's official GPG key:
            apt-get update
            apt-get install ca-certificates curl unzip
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc


            # Add the repository to Apt sources:
            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update

            # Installing Docker
            apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            ./aws/install

            aws ecr get-login-password --region me-south-1 | docker login --username AWS --password-stdin 195853814676.dkr.ecr.me-south-1.amazonaws.com

            docker pull 195853814676.dkr.ecr.me-south-1.amazonaws.com/corvit/db3:latest

            docker run -d -p 80:80 --name portfolio_container 195853814676.dkr.ecr.me-south-1.amazonaws.com/corvit/db3:latest
            EOF

    tags = {
        Name = "WEB-EC2"
    }
}

resource "aws_eip" "ec2_eip" {}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.ec2_eip.id
}

output "ec2_public_ip" {
  value = aws_eip.ec2_eip.public_ip
  description = "Public IP of the EC2 instance"
}
