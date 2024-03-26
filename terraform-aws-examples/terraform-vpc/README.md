# terraform-test
1.create VPC
2.Two subnets
3. one public subnet with internet gw
4. with three http ec2s in ELB
3. one private subnet with nat gw
5 with two dd EC2

Please use your aws own profile`

create ssh key
ssh-keygen -t rsa -m PEM 
you can copy id_rsa to anyname.pem
then
chmod 400 anyname.pem
you will use "ssh -i anyname.pem ubuntu@ec2dnsname

then create
public key file
ssh-keygen -y -f /path_to_key_pair/anyname.pem >> terraform_ec2_key.pub

