output "instance_ips" {
  value = {
    for i, inst in aws_instance.app :
    i => {
      id = inst.id
      private_ip = inst.private_ip
      public_ip  = inst.public_ip
      tags = inst.tags
    }
  }
  sensitive = false
}