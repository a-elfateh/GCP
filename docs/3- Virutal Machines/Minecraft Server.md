# Working with Google Cloud's Virtual Machines
In this tutioral, we will get to do get oud hands dirty with some of Google Cloud's Virtual Machines features from setting up a VM, customizing boot disks, cron jobs, startup/shudown scripts, utilizing reserved IP addresses, and finaly disk backups and snapshots.
# What's the plan exactly?
We will customize a virtual machine instance by installing base software, which's a headless Java runtime environment and application software, specifically, a **Minecraft game server 🛠️🧱💎** . Will customize the VM by preparing and attaching a high-speed SSD to match the game server's performance. 

We will also need a reserved a static external IP address; so we don't get bothered each time accessing the game by Google Cloud's ephermeral pool. We will take the IP and check the availability of the the gaming server on an outsource website.

We will set up a backing mechanisim by creating a Cloud Storage bucket, and backup up to it in a regural manner using cron jobs.

Finally, as most administrative roles require their personnel to automate some startup and shutdown tasks, we will take advantage of startup/shutdown scripts.


## Minecraft game server 🛠️🧱💎
Let's starting building now 🛠️. Fire up the cloud shell on the top left corner of the cloud console.

```
gcloud compute disks create mine-disk --type pd-ssd --size 50 --zone us-west1-c
```

```
gcloud compute addresses create mine-address --region us-west1
```

```
gcloud compute firewall-rules create mine-fw --action allow --source-ranges 0.0.0.0/0 --rules tcp:25565
```

```
gcloud compute instances create mine-server --zone us-west1-c --machine-type e2-medium --disk=name=mine-disk,mode=rw --address mine-address --tags mine-fw
```

```
gcloud compute ssh mine-server --zone us-west1-c
```

```
sudo mkdir -p /home/minecraft
```

```
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-persistent-disk-1
```

```
sudo mount -o discard,defaults /dev/disk/by-id/google-persistent-disk-1 /home/minecraft
```

```
df -h /home/minecraft
```

```
sudo apt-get update
```

```
sudo apt-get install -y default-jre-headless
```

```
cd /home/minecraft && sudo apt-get install wget
```

```
sudo wget https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar
```

```
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui
```

```
sudo nano eula.txt
```

** edit the **
