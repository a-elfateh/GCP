# Update package lists and install BIND9 (DNS server) and dnsutils (DNS utilities)
sudo apt update && sudo apt install -y bind9 && sudo apt install -y dnsutils

# Capture the current machine's IP address into the DNS_IP variable
DNS_IP=$(hostname -I | awk '{print $1}')

# Get the IP address of the NGINX server by performing an nslookup and extracting the IP address
NGINX_IP=$(nslookup nginx | awk '/^Address: / {print $2}' | tail -n1)

# Generate the reverse IP address (for reverse DNS) by rearranging the first three octets of the DNS_IP
REVERSE_IP=$(echo $DNS_IP | awk -F '.' '{print $3"."$2"."$1}')

# Extract the first octet of the DNS_IP for use in reverse DNS configuration
REVERSE_IP_FIRST_OCTET=$(echo $DNS_IP | awk -F '.' '{print $1}')

# Create the BIND9 configuration files for DNS options and zones at /etc/bind/
sudo bash -c "echo 'options {
        directory "'"/var/cache/bind"'";

        forwarders {
        8.8.8.8;
        };

        recursion yes;                    # Enable recursion
        allow-recursion { any; };  # Allow recursion for the specified network

        allow-query { any; };              # Allow all clients to query the server
        allow-query-cache { any; };        # Allow all clients to use cached responses

        dnssec-validation auto;

        listen-on-v6 { any; };
};' > /etc/bind/named.conf.options && sudo echo -e 'zone "'"dns.local"'" {
        type master;
        file "'"/etc/bind/db.dns.local"'";
};
zone \"${REVERSE_IP}.in-addr.arpa\" {
        type master;
        file "'"/etc/bind/db.10"'";
};' > /etc/bind/named.conf.local && sudo echo -e '@       IN      SOA     dns.local. root.dns.local. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ad1.dns.local.
@       IN      A       $DNS_IP
ad1     IN      A       $DNS_IP
@       IN      AAAA    ::1
nginx   IN      A       $NGINX_IP' > /etc/bind/db.dns.local && sudo echo -e ';
; BIND reverse data file for broadcast zone
;
\$TTL    604800
@       IN      SOA     ad1.dns.local. root.dns.local. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ad1.
$REVERSE_IP_FIRST_OCTET      IN      PTR     ad1.dns.local.' > /etc/bind/db.10 

# Restart the BIND9 service to apply the changes
sudo systemctl restart bind9"

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
