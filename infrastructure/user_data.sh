#!/bin/bash

# Configure cluster name using the template variable
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config

# Update system packages
yum update -y

# Install required packages
yum install -y clamav nmap cronie curl

# Update ClamAV database
freshclam

# Create ClamAV scan script
cat << 'EOF' > /usr/local/bin/clamav_scan.sh
#!/bin/bash
clamscan -r / --exclude-dir=/sys --exclude-dir=/proc --log=/var/log/clamav_scan.log
EOF
chmod +x /usr/local/bin/clamav_scan.sh

# Schedule ClamAV cron job to run daily at midnight
echo "0 0 * * * /usr/local/bin/clamav_scan.sh" >> /var/spool/cron/root

# Create Nmap scan script
cat > /usr/local/bin/nmap_scan.sh << 'EOSCRIPT'
#!/bin/bash
ip -o -f inet addr show | grep 'scope global' | while read -r line
do
  subnet=$(echo "$line" | awk '{print $4}')
  logfile=$(echo "$subnet" | sed 's/\//_/g')
  nmap -Pn -T4 -oN "/var/log/nmap_scan_$logfile.log" "$subnet"
done
EOSCRIPT

chmod +x /usr/local/bin/nmap_scan.sh

# Schedule Nmap cron job to run daily at midnight
echo "0 0 * * * /usr/local/bin/nmap_scan.sh" >> /var/spool/cron/root

# Create API health check script
cat > /usr/local/bin/api_health_check.sh << 'EOSCRIPT'
#!/bin/bash
response=$(curl -s -o /dev/null -w '%%{http_code}' https://in-store-app.co.uk/api/health)
echo "$(date) - API Status: $response" >> /var/log/api_health_check.log
EOSCRIPT

chmod +x /usr/local/bin/api_health_check.sh

# Schedule API health check cron job to run hourly
echo "0 * * * * /usr/local/bin/api_health_check.sh" >> /var/spool/cron/root