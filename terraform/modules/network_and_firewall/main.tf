resource "aws_lightsail_static_ip" "this" {
  name = var.static_ip_name
}

resource "aws_lightsail_static_ip_attachment" "this" {
  static_ip_name = aws_lightsail_static_ip.this.name
  instance_name  = var.instance_name
}

resource "aws_lightsail_instance_public_ports" "this" {
  instance_name = var.instance_name

  dynamic "port_info" {
    for_each = var.allowed_ports
    content {
      protocol  = port_info.value.protocol
      from_port = port_info.value.from_port
      to_port   = port_info.value.to_port
      cidrs     = port_info.value.cidrs
    }
  }
}
