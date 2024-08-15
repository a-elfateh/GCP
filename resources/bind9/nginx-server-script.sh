# Update the package list to ensure the latest versions of packages are available.
sudo apt update

# Install Nginx, a popular web server, to handle HTTP requests.
sudo apt install -y nginx

# Install dnsutils, a package that provides tools like nslookup for DNS querying.
sudo apt install -y dnsutils

# Use nslookup to find the IP address of the DNS server and store it in the variable DNS_IP.
# The awk command extracts the IP address from the output, and tail ensures the last match is used.
DNS_IP=$(nslookup dns | awk '/^Address: / {print $2}' | tail -n1)

# Grant write permissions to the group for the resolved.conf file so modifications can be made.
sudo chmod g+w /etc/systemd/resolved.conf

# Append the DNS server IP and domain information to the systemd resolved configuration file.
sudo bash -c " echo 'DNS= $DNS_IP 169.254.169.254' >> /etc/systemd/resolved.conf && echo 'Domains= $(cat /etc/resolv.conf | awk '                                                                                                      /^domain/ { printf "dns.local " }
    /^search/ { printf "%s\n", substr($0, index($0,$2)) }
    /^nameserver/ { exit }') ' >> /etc/systemd/resolved.conf"

# Append a configuration to the DHCP client to supersede the default DNS server with your DNS server IP.
sudo bash -c "echo 'supersede domain-name-servers $DNS_IP;' >> /etc/dhcp/dhclient.conf"

# Restart the systemd-resolved service to apply the new DNS settings.
sudo systemctl restart systemd-resolved

# Ensure /etc/resolv.conf is correctly linked to the systemd-resolved configuration.
sudo systemctl restart systemd-resolved && sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
