#!/bin/bash
apt update
apt install -y apache2

# Get the instance ID using the instance metadata
#INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
</head>
<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Main Page</h2>
  <p>Welcome to my page!</p>
  
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2
