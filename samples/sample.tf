# Single line comment

// Alternative comment style

/*
Multi-line
comment block
*/

# --- Variables ---
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 2
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "development"
    Project     = "sample"
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# --- Locals ---
locals {
  common_tags = {
    ManagedBy = "terraform"
    Project   = var.tags["Project"]
  }
  name_prefix = "sample-${var.tags["Environment"]}"
}

# --- Data source ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Resources ---
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-${count.index}"
  })

  monitoring = var.enable_monitoring
}

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for web servers"

  # Dynamic block with for_each
  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- For expressions ---
locals {
  instance_ids = [for instance in aws_instance.web : instance.id]

  instance_map = {
    for instance in aws_instance.web :
    instance.tags["Name"] => instance.id
  }

  filtered = [for id in local.instance_ids : id if id != ""]
}

# --- Conditional ---
resource "aws_eip" "web" {
  count    = var.enable_monitoring ? var.instance_count : 0
  instance = aws_instance.web[count.index].id
}

# --- Functions ---
locals {
  upper_name   = upper(local.name_prefix)
  joined       = join(",", var.availability_zones)
  encoded      = base64encode("Hello, World!")
  timestamp    = formatdate("YYYY-MM-DD", timestamp())
  file_content = file("${path.module}/sample.tf")
  length       = length(var.availability_zones)
  lookup_val   = lookup(var.tags, "Environment", "unknown")
  coalesce_val = coalesce(null, "", "default")
}

# --- Outputs ---
output "instance_ids" {
  description = "IDs of created instances"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IPs"
  value       = [for instance in aws_instance.web : instance.public_ip]
  sensitive   = false
}

# --- Numbers ---
locals {
  integer_val = 42
  float_val   = 3.14
  negative    = -17
  scientific  = 1e10
}

# --- Null ---
locals {
  nothing = null
}
