sudo apt update && sudo apt install -y bind9

DNS_IP=$(hostname -I | awk '{print $1}')
NGINX_IP=$(nslookup nginx | awk '/^Address: / {print $2}' | tail -n1)
REVERSE_IP=$(echo $DNS_IP | awk -F '.' '{print $3"."$2"."$1}')
REVERSE_IP_FIRST_OCTET=$(echo $DNS_IP | awk -F '.' '{print $1}')
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
$REVERSE_IP_FIRST_OCTET      IN      PTR     ad1.dns.local.' > /etc/bind/db.10 && sudo systemctl restart bind9"
