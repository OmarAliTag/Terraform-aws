#!/bin/bash
# Install and configure Apache web server

yum update -y
yum install -y httpd

# Create a simple web page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Backend Server</title>
</head>
<body>
    <h1>Backend Web Server</h1>
    <p>Hostname: $(hostname)</p>
    <p>Private IP: $(hostname -I | awk '{print $1}')</p>
    <p>Timestamp: $(date)</p>
</body>
</html>
EOF

systemctl enable httpd
systemctl start httpd