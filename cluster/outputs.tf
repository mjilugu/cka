output "cka-master-1-ip" {
    description = "public ip address of master 1"
    value = aws_instance.cka-master-1.public_ip
}

output "cka-worker-1-ip" {
    description = "public ip address of worker 1"
    value = aws_instance.cka-worker-1.public_ip
}

output "cka-worker-2-ip" {
    description = "public ip address of worker 2"
    value = aws_instance.cka-worker-2.public_ip
}