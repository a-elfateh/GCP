# Hosting a DNS Server on a GCP Compute Instance:
Hosting a DNS server on a Google Cloud Platform (GCP) Compute Engine instance versus using a private hosted zone in GCP’s Cloud DNS are two different approaches to managing DNS, each with its own advantages and use cases. Here’s a quick overview of considerations before choosing:

**Control:** Hosting on a GCP Compute Instance provides full control and customization, while GCP’s Cloud DNS offers a managed service with less flexibility.

**Maintenance:** Hosting your own DNS server requires more maintenance, whereas GCP’s Cloud DNS is maintained by Google.

**Scalability and Reliability:** GCP Cloud DNS scales automatically and offers high reliability, while a self-hosted DNS server requires manual scaling and configuration for high availability.

**Integration:** GCP Cloud DNS integrates seamlessly with other GCP services, making it easier to manage DNS in a GCP-centric environment.

# When to Choose Each

Host on **Compute Engine** if you need custom DNS configurations, advanced features, or tight integration with non-GCP systems.

Use **Cloud DNS** if you prefer a managed service that integrates with GCP, requires less maintenance, and provides high scalability and reliability.

# Setting up custome DNS server on Compute Engine:
In this setup, we'll be configuring a DNS server using BIND9 on Google Cloud Platform. To validate the DNS configuration, we'll deploy an NGINX instance and add an A record that points to this NGINX server. This setup will allow us to ensure that DNS resolution is functioning correctly, making it a reliable solution for future projects.

I have already went and created ready scripts that do all needed configuration in both the DNS and NGINX servers.   

## Steps:
1- Login to your GCP account and fire up cloud shell. Make sure that the Compute Engine API is enabled. If no run the following command to enable the api
```
gcloud services enable compute.googleapis.com
```

2- Store a variable vlaue of the zone you want to create the DNS and NGINX server in
```
export ZONE= ZONE_NAME
```

3- Create 2 instances. One for the NGINX server and another one for the DNS server
```
gcloud compute instances create nginx --zone $ZONE --boot-disk-size 50gb --machine-type e2-micro
gcloud compute instances create dns --zone $ZONE --boot-disk-size 50gb --machine-type e2-micro
```

4- Let's configure the NGINX settings first. SSH into the ```nginx``` machine
```
gcloud compute ssh nginx --zone $ZONE
```

5- Install Git and clone the repo to the machine
```
sudo apt update && sudo apt install -y git
git clone https://github.com/a-elfateh/GCP/
```

6- Change the permissions of the script and make it executable
```
chmod +x ~/GCP/resources/bind9/nginx-server-script.sh
```
