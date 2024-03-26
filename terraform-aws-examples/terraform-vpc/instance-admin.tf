#### INSTANCE Admin ####

# Create instance
resource "aws_instance" "admin1" {
  for_each      = var.admin1_instance_names
  ami           = var.aws_amis[var.aws_region]
  instance_type = "t3.medium"
  key_name      = "terraform1"
  vpc_security_group_ids = [
    aws_security_group.administration.id,
    aws_security_group.web.id,
  ]
  subnet_id = aws_subnet.admin1.id
  tags = {
    Name = each.key
  }
}


# Attach floating ip on instance http
resource "aws_eip" "public_admin1" {
  for_each   = var.admin1_instance_names
  vpc        = true
  instance   = aws_instance.admin1[each.key].id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "public-admin1-${each.key}"
  }
}
# Create instance
resource "aws_instance" "admin2" {
  for_each      = var.admin2_instance_names
  ami           = var.aws_amis[var.aws_region]
  instance_type = "t3.medium"
  key_name      = "terraform1"
  vpc_security_group_ids = [
    aws_security_group.administration.id,
    aws_security_group.web.id,
  ]
  subnet_id = aws_subnet.admin2.id
  tags = {
    Name = each.key
  }
}


# Attach floating ip on instance http
resource "aws_eip" "public_admin2" {
  for_each   = var.admin2_instance_names
  vpc        = true
  instance   = aws_instance.admin2[each.key].id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "public-admin2-${each.key}"
  }
}
