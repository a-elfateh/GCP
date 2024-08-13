sudo apt update
sudo apt install -y nginx
sudo apt install -y dnsutils
DNS_IP=$(nslookup dns | awk '/^Address: / {print $2}' | tail -n1)
echo $DNS_IP
sudo chmod g+w /etc/systemd/resolved.conf
sudo bash -c "echo -e 'DNS= $DNS_IP 169.254.169.254
Domains= dns.local us-central1-f.c.dns-menkish.internal. c.dns-menkish.internal. google.internal.' >>         /etc/systemd/resolved.conf"
sudo echo "supersede domain-name-servers $DNS_IP;" >> /etc/dhcp/dhclient.conf
sudo systemctl restart systemd-resolved
sudo systemctl restart systemd-resolved && sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
