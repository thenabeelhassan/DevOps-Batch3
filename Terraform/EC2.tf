resource "aws_instance" "PrivateEC2" {
    ami = "ami-0bdb4b5c0e2417d4f"
    availability_zone = "me-south-1b"
    instance_type = "t3.micro"
    key_name = "AWS-Class"
    subnet_id = "subnet-08278f0f1eee4462c"
    tags = {
        Name = "jan11"
    }
    vpc_security_group_ids = [ "sg-0587cfd551e03261c" ]
}