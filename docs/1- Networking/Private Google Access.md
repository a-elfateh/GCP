# Private Google Access
As a general security best practice in the cloud, utilizng private machines only wherever possible.
When you decide to use private machines, upon deploying the VM you restrict the vm from using external IP, leaving it only with its internal IP. 

**A question though, How can such VMs communicate with exteranl APIs, Cloud services, or even accessing the internet for updates, patching, configuration...etc?**
Here's where Private Google Access & Cloud NAT comes into play.

# How does Private Google Access Work exactly? 
You enable Private Google Access on a subnet-by-subnet basis. You should enable Private Google Access to allow VM instances that only have internal IP addresses to reach the external IP addresses of Google APIs and services. For example, if your private VM instance needs to access a Cloud Storage bucket (which we will do in this lab), you need to enable Private Google Access.

## Lab Objectives
- Configure a VM instance that doesn't have an external IP address
- Connect to a VM instance using an Identity-Aware Proxy (IAP) tunnel
- Enable Private Google Access on a subnet
- Verify access to public IP addresses of Google APIs and services and other connections to the internet

## Lab Steps:
1- On GCP, open the cloud shell and create a custom mode VPC, a subnet, and the needed firewall rules to ssh into a VM will be creating later.
```
gcloud compute networks create privatenet --subnet-mode custom
```

```
gcloud compute networks subnets create privatenet-us --network privatenet --region us-east1 --range 10.130.0.0/20
```

```
gcloud compute firewall-rules create privatenet-ssh --network privatenet --action allow --rules tcp:22
```


2- Create a VM with only internal IP and has no external IP (will sit privatly on the Google Cloud network)
```
gcloud compute instances create privatenet-vm --machine-type e2-micro --subnet privatenet-us --zone us-east1-d --no-address
```
**The --no-address option is used to set the vm with no external IP**


3- Let's create a bucket to test the connection from the vm we just created to that bucket. **Please make sure that your bucket name is unique**
```
gsutil mb gs://unique-bucket-name 
```

4- Will ssh into the machine we just created utilizing the tunnel-through-iap API, where VM's that have no external IP address can be ssh'ed into.
```
gcloud compute ssh privatenet-vm --zone us-east1-d --tunnel-through-iap
```

5- Test the connectivity to the bucket you just created
```
gcloud storage ls
```
** This should return nothing, as the vm currently cannot communicate with other services due to the lack of an external IP address**


6- Open a new cloud shell tab alongside the current one where you are accessing the privatenet-vm. Will now enable Private Google Access on the privatenet-us subnet
```
gcloud compute networks subnets update privatenet-us --region=us-east1 --enable-private-ip-google-access
```

7- Will return now to the first window to check the effect of Private Google Access on the subnet
```
gsutil ls
```
Let's copy some files from a public bucket to our VM
```
gsutil cp gs://cloud-training/gcpnet/private/access.svg .
```

This shows you the power of this feature available on Google Cloud, which by you can use your VMs behind Google's global private network, prohibiting the VM from accessing the internet for security best practices, and enable this feature whenever you need it to access other Google Cloud services and Google APIs.
