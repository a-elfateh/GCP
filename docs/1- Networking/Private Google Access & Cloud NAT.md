# Private Google Access & Cloud NAT
As a general security best practice in the cloud, utilizng private machines only wherever possible.
When you decide to use private machines, upon deploying the VM you restrict the vm from using external IP, leaving it only with its internal IP. 

**A question though, How can such VMs communicate with exteranl APIs, Cloud services, or even accessing the internet for updates, patching, configuration...etc?**
