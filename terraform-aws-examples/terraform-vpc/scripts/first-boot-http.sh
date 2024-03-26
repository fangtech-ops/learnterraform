#!/bin/bash

echo "hello world"

apt update
apt install apache2 -y
cat <<EOF >/var/www/html/index.html
<!DOCTYPE html> 
  
<html> 
    <head> 
        <title> 
            First Web Page 
        </title> 
    </head> 
  
    <body> 
        <h1>Hello World!</h1> 
        <h2>Hello World!</h2> 
        <h3>Hello World!</h3> 
        <h4>Hello World!</h4> 
        <h5>Hello World!</h5> 
        <h6>Hello World!</h6> 
    </body> 
</html> 
EOF
systemctl start apache2
systemctl enable apache2

