# Private Google Access & Cloud NAT
As a general security best practice in the cloud, utilizng private machines only wherever possible.
When you decide to use private machines, upon deploying the VM you restrict the vm from using external IP, leaving it only with its internal IP. 

**A question though, How can such VMs communicate with exteranl APIs, Cloud services, or even accessing the internet for updates, patching, configuration...etc?**
Here where Private Google Access & Cloud NAT comes into play.

# Private Google Access 
You enable Private Google Access on a subnet-by-subnet basis. You should enable Private Google Access to allow VM instances that only have internal IP addresses to reach the external IP addresses of Google APIs and services. For example, if your private VM instance needs to access a Cloud Storage bucket (which we will do in this lab), you need to enable Private Google Access.

## Lab Objictives
- Configure a VM instance that doesn't have an external IP address
- Connect to a VM instance using an Identity-Aware Proxy (IAP) tunnel
- Enable Private Google Access on a subnet
- Configure a Cloud NAT gateway
- Verify access to public IP addresses of Google APIs and services and other connections to the internet
