# HA Virtual Private Network
HA VPN (High Availability VPN) is a Cloud VPN solution that lets you securely connect your on-premises network to your Virtual Private Cloud (VPC) network through an IPsec VPN connection in a single region. The availability of the HA VPN comes from configure two or four tunnels from your HA VPN gateway to your peer VPN on-prem device, or another HA VPN gateway.

Upon creating an HA VPN gateway, Google Cloud automatically chooses 2 external IP addresses, one for each of its fixed number of two interfaces. Each IP address is automatically chosen from a unique address pool to provide the high availability.

# Dynamic routing with Cloud Router
Cloud Router can manage routes for a Cloud VPN tunnel using Border Gateway Protocol(BGP). This routing method allows for routes to be updated and exchanged without changing the tunnel configuration. 

To automatically propagate network configuration changes, the VPN tunnel uses Cloud Router to establish a BGP session between the VPC and the on-premises VPN gateway, which must support BGP. Any new subnets are then seamlessly advertised between networks. This means that instances in the new subnets can start sending and receiving traffic immediately which is demonstrated in the following tutorial.

In order to configure BGP routing, each end of the VPN tunnel must use a unique IP address. These 2 addresses are link-local IP addresses belonging to the 169.254.0.0/16 IP range.

# Tutorial

![VLAXpKCCD3vR0NwjlabV3gVp9Zzf1PPu7D91KCm9VY4=](https://github.com/a-elfateh/Things/assets/61758821/ddf3eb81-c6f3-4721-a3c9-e0f2b3a00c96)

To apply what previously mentioned, In this tutorial we'll create a global VPC called ```vpc-demo```, with two custom subnets in us-east1 and us-central1. In this VPC, we'll add a Compute Engine instance in each region. Then create a second VPC called ```on-prem``` to simulate a customer's on-premises data center. In this second VPC, we'll add a subnet in region us-central1 and a Compute Engine instance running in this region. 

Then, we'll add an HA VPN and a cloud router in each VPC and run two tunnels from each HA VPN gateway before testing the configuration to verify the 99.99% SLA. 

Finally, we will create another subnet on ```vpc-demo``` and an instance on it to demostrate the seamless advertisment between networks without needing to configure any additional thing.

**Lab Objectivies:**
- Create two VPC networks and instances.
- Configure HA VPN gateways.
- Configure dynamic routing with VPN tunnels.
- Configure global dynamic routing mode.
- Verify and test HA VPN gateway configuration.
- Verify seamless dynamic routing

1- First let's start by configuring the ```vpc-demo``` network
```
gcloud compute networks create vpc-demo --subnet-mode custom
```

2- Create 2 subnets called ```vpc-demo-subnet1``` & ```vpc-demo-subnet1``` in us-central1 and us-east4 respectively
```
gcloud compute networks subnets create vpc-demo-subnet1 --network vpc-demo --range 10.1.1.0/24 --region us-central1
gcloud compute networks subnets create vpc-demo-subnet2 --network vpc-demo --range 10.2.1.0/24 --region us-east4
```

3- Let's now create a firewall rule that allows all internal connectivity within tbe subnets
```
gcloud compute firewall-rules create vpc-demo-allow-internal \
--network vpc-demo \
--action allow --rules tcp:0-65535,udp:0-65535,icmp \
--source-ranges 10.0.0.0/8
```

4- Create a firewall rule to allow connecting to the instances of the 2 subnets through the "ssh" protocol
```
gcloud compute firewall-rules create vpc-demo-allow-ssh-icmp \
--network vpc-demo \
--action allow --rules tcp:22
```

5- Now let's create an instance in each subnet withing the ```vpc-demo``` VPC
```
gcloud compute instances create vpc-demo-instance1 \
--machine-type e2-micro \
--network vpc-demo --subnet vpc-demo-subnet1 --zone us-central1-f
```

```
gcloud compute instances create vpc-demo-instance2 \
--machine-type e2-micro \
--network vpc-demo --subnet vpc-demo-subnet2 --zone us-east4-a
```

6- Will now do the same steps we did on the ```vpc-demo``` to create a simulated on-premise network called ```on-prem``` VPC

```
gcloud compute networks create on-prem --subnet-mode custom
```

7- Create only one subnet on the ```on-prem``` VPC
```
gcloud compute networks subnets create on-prem-subnet1 --network on-prem --range 192.168.1.0/24 --region us-central1
```

8- Create the needed firewall rules to allow internal connectivity and to allow ssh to vm instances
```
gcloud compute firewall-rules create on-prem-allow-internal \
--network on-prem --action allow --rules tcp:0-65535,udp:0-65535,icmp \
--source-ranges 192.168.0.0/16
```

```
gcloud compute firewall-rules create on-prem-allow-ssh-icmp \
--network on-prem --action allow --rules tcp:22
```

9- Create an instance on the ```on-prem``` VPC
```
gcloud compute instances create on-prem-instance --machine-type e2-micro --subnet on-prem-subnet1 --zone us-central1-a
```

**We will start now configuring the VPN connectivity**

10- Create a VPN gateway in each VPC network
```
gcloud compute vpn-gateways create vpc-demo-vpn-gw1 --network vpc-demo --region us-central1
```

```
gcloud compute vpn-gateways create on-prem-vpn-gw1 --network on-prem --region us-central1
```

**You can check the details of the gateways using the following command**
```
gcloud compute vpn-gateways describe vpc-demo-vpn-gw1 --region us-central1
```

11- Will now need to configure a router on each VPC network
```
gcloud compute routers create vpc-demo-router1 \
    --region us-central1 \
    --network vpc-demo \
    --asn 65001
```

```
gcloud compute routers create on-prem-router1 \
    --region us-central1 \
    --network on-prem \
    --asn 65002
```

12- Now we are able to create VPN tunnels between the two gateways. 

**Please note: For HA VPN setup, you add two tunnels from each gateway to the remote setup. You create a tunnel on interface0 and connect to interface0 on the remote gateway. Next, you create another tunnel on interface1 and connect to interface1 on the remote gateway.**

**When you run HA VPN tunnels between two Google Cloud VPCs, you need to make sure that the tunnel on interface0 is connected to interface0 on the remote VPN gateway. Similarly, the tunnel on interface1 must be connected to interface1 on the remote VPN gateway.**

**Create the first VPN tunnel in the vpc-demo network**
```
gcloud compute vpn-tunnels create vpc-demo-tunnel0 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 0

```

**Create the second VPN tunnel in the vpc-demo network**
```
gcloud compute vpn-tunnels create vpc-demo-tunnel1 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 1
```

**Create the first VPN tunnel in the on-prem network**
```
gcloud compute vpn-tunnels create on-prem-tunnel0 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 0
```

**Create the second VPN tunnel in the on-prem network**
```
gcloud compute vpn-tunnels create on-prem-tunnel1 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 1
```

13- Let's configure BGP peering for each VPN tunnel between vpc-demo and VPC on-prem

**Start with setting the router interface for tunnel0 in network vpc-demo, and create the BGP peer for tunnel0**
```
gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel0-to-on-prem \
    --ip-address 169.254.0.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel0 \
    --region us-central1
```

```
gcloud compute routers add-bgp-peer vpc-demo-router1 \
    --peer-name bgp-on-prem-tunnel0 \
    --interface if-tunnel0-to-on-prem \
    --peer-ip-address 169.254.0.2 \
    --peer-asn 65002 \
    --region us-central1
```

**Set the router interface for tunnel1 in network vpc-demo, and create the BGP peer for tunnel1**
```
gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel1-to-on-prem \
    --ip-address 169.254.1.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel1 \
    --region us-central1
```

```
gcloud compute routers add-bgp-peer vpc-demo-router1 \
    --peer-name bgp-on-prem-tunnel1 \
    --interface if-tunnel1-to-on-prem \
    --peer-ip-address 169.254.1.2 \
    --peer-asn 65002 \
    --region us-central1
```

**Set the router interface for tunnel0 in network on-prem, and create the BGP peer for tunnel0**
```
gcloud compute routers add-interface on-prem-router1 \
    --interface-name if-tunnel0-to-vpc-demo \
    --ip-address 169.254.0.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel0 \
    --region us-central1
```

```
gcloud compute routers add-bgp-peer on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel0 \
    --interface if-tunnel0-to-vpc-demo \
    --peer-ip-address 169.254.0.1 \
    --peer-asn 65001 \
    --region us-central1
```

**Set the router interface for tunnel1 in network on-prem, and create the BGP peer for tunnel1**
```
gcloud compute routers add-interface  on-prem-router1 \
    --interface-name if-tunnel1-to-vpc-demo \
    --ip-address 169.254.1.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel1 \
    --region us-central1
```

```
gcloud compute routers add-bgp-peer  on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel1 \
    --interface if-tunnel1-to-vpc-demo \
    --peer-ip-address 169.254.1.1 \
    --peer-asn 65001 \
    --region us-central1
```


**Verify router configurations through the following commands:**
```
gcloud compute routers describe vpc-demo-router1 --region us-central1
```

```
gcloud compute routers describe on-prem-router1 --region us-central1
```


14- We will test private connectivity now, open up a new cloud shell window next to the original one and run the following command to view the details of the instances we created earlier

```
gcloud compute instances list
```

**Connect to the on-prem instance throw ssh**
```
gcloud compute ssh on-prem-instance --zone us-central1-a
```

**Verify internal connectivity over private addresses. Ping the vpc-demo instances, first ping the vpc-demo-instance1**

```
ping 10.1.1.2
```

**Now ping the vpc-demo-instance2**

```
ping 10.2.1.2
```

**Notice that there are no replies to both instancecs. Currently the VPN connectivity between both tunnels is established and the ping should work, the reason that there're no replies is that firewall rules aren't configured yet to allow any type of connection over internal addresses. Let's configure the needed firewall rules, return to the first tab and run the following commands**

```
gcloud compute firewall-rules create vpc-demo-allow-subnets-from-on-prem \
    --network vpc-demo \
    --allow tcp,udp,icmp \
    --source-ranges 192.168.1.0/24
```

```
gcloud compute firewall-rules create on-prem-allow-subnets-from-vpc-demo \
    --network on-prem \
    --allow tcp,udp,icmp \
    --source-ranges 10.1.1.0/24,10.2.1.0/24
```

**Now return to the second cloud shell window where we're currntly connected to the ```on-prem-instance```. Ping both vpc-demo instances**

```
ping 10.1.1.2
```

```
ping 10.2.1.2
```

**Now we are able to reach the vpc-demo insatnces securly and privatly through the VPN connection. Exit the ```on-prem-instance```**

```
exit
```

**SSH to the ```vpc-demo-instance1```**

```
gcloud compute ssh vpc-demo-instance1 --zone=us-central1-f
```
**Ping the private address of the ```on-prem-instance1``` to verify internal connectivity**

```
ping 192.168.1.2
```

**Everything looks great now. Exit from the ```on-prem-instance1```**

```
exit
```

**SSH to the ```vpc-demo-instance2```**

```
gcloud compute ssh vpc-demo-instance2 --zone=us-east4-a 
```

**Ping the private address of the ```on-prem-instance1``` to verify internal connectivity**

```
ping 192.168.1.2
```

**Notice that there's no reply from the private address of the ```on-prem-instance1```. That's because HA VPN is a regional resource and cloud router by default only sees the routes in the region in which it is deployed. To reach instances in a different region than the cloud router, you need to enable global routing mode for the VPC. This allows the cloud router to see and advertise routes from other regions**

**Swith to the first tab and run the following command to enable global routing for the ```vpc-demo``` network**

```
gcloud compute networks update vpc-demo --bgp-routing-mode GLOBAL
```

**Return to the second tab where we are currently connected to the ```vpc-demo-instance2```, try now to ping the private address of the ```on-prem-instance1```**

```
ping 192.168.1.2
```

**We're getting replies now. That's because we enabled Global BGP Routing. Exit from the ```vpc-demo-instance2```, and switch to the first cloud shell tab**

15- Create a new subnet in the ```vpc-demo``` subnet, and an instance on the newly created subnet. **Make sure that the new subnet is on a region different that ```vpc-demo-subnet1``` & ```vpc-demo-subnet2```**

```
gcloud compute networks subnets create vpc-demo-subnet3 --network vpc-demo --range 10.3.1.0/24 --region europe-west1
```

```
gcloud compute instances create vpc-demo-instance3 \
--machine-type e2-micro \
--network vpc-demo --subnet vpc-demo-subnet3 --zone europe-west1-b
```

16- Let's test if instances in any newly created subnets can send and receive traffic immediately. Create a firewall rule to allow traffic coming from ```vpc-demo-subnet3``` into the ```on-prem``` network.

```
gcloud compute firewall-rules create on-prem-allow-vpc-demo-subnet3 \
    --network on-prem \
    --allow tcp,udp,icmp \
    --source-ranges 10.3.1.0/24
```

**Switch to the second tab and ssh to the ```vpc-demo-instance3```**

```
gcloud compute ssh vpc-demo-instance3 --zone europe-west1-b
```

**Test the connectivity from ```vpc-demo-instance3``` to the ```on-prem-instance```

```
ping 192.168.1.2
```

**Seamless connectivity looking great. Now we don't need to worry from extra configurations if we added any new subnets either on-prem or on the cloud**

**Switch to the first tab**

16- Delete one of the vpn-tunnels in order to test the high-availability of our HA VPN.

```
gcloud compute vpn-tunnels delete vpc-demo-tunnel0  --region us-central1
```
**Verify that the tunnel is down by running the following command. The detailed status should show as Handshake_with_peer_broken.**

```
gcloud compute vpn-tunnels describe on-prem-tunnel0  --region us-central1
```

**Return to the second tab where we are connected to the ```vpc-demo-instance3``` to test if the VPN connectivity still works. Ping the ```on-prem-instance```**

```
ping 192.168.1.2 
```

**Pings are still successful because the traffic is now sent over the second tunnel. You have successfully configured HA VPN tunnels.**
