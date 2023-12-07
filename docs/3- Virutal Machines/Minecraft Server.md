# Working with Google Cloud's Virtual Machines
In this tutioral, we will get to do get oud hands dirty with some of Google Cloud's Virtual Machines features from setting up a VM, customizing boot disks, startup/shudown scripts, utilizing reserved IP addresses.
# What's the plan exactly?
We will customize a virtual machine instance by installing base software, which's a headless Java runtime environment and application software, specifically, a **Minecraft game server 🛠️🧱💎** . Will customize the VM by preparing and attaching a high-speed SSD to match the game server's performance. 

We will also need a reserved a static external IP address; so we don't get bothered each time accessing the game by Google Cloud's ephermeral pool. We will take the IP and check the availability of the the gaming server on an outsource website.

Finally, as most administrative roles require their personnel to automate some startup and shutdown tasks, we will take advantage of startup/shutdown scripts.


## Minecraft game server 🛠️🧱💎
Let's starting building now 🛠️. Fire up the cloud shell on the top left corner of the cloud console.

1- First, create the gaming disk that will hold the minecraft server. I will choose us-west1
```
gcloud compute disks create mine-disk --type pd-ssd --size 50 --zone us-west1-c
```

2- Next, reserve an IP address which we will attach as an extranl IP for our minecraft server
```
gcloud compute addresses create mine-address --region us-west1
```

3- We will also need to enable traffic through port 25565, which is the port the game uses for enabling traffic to and from the server.
```
gcloud compute firewall-rules create mine-fw --action allow --source-ranges 0.0.0.0/0 --rules tcp:25565
```

4- Now we will create the gaming server, making sure to add all of what we created earlier. In the options of the follwing command, make sure to attach the gaming disk, the reserved ip address, and add the firewall rule we created by tagging the firewall rule name to the instance.
```
gcloud compute instances create mine-server --zone us-west1-c --machine-type e2-medium --disk=name=mine-disk,mode=rw --address mine-address --tags mine-fw
```

5- Let's ssh to our VM now.
```
gcloud compute ssh mine-server --zone us-west1-c
```

6- We will create a directory to attach to it the disk we prepared
```
sudo mkdir -p /home/minecraft
```

7- Run the following commands to format and prepare the disk
```
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-persistent-disk-1
```

```
sudo mount -o discard,defaults /dev/disk/by-id/google-persistent-disk-1 /home/minecraft
```

8- Run this command to check if everything went well, and that the disk has been mounted in the /home/minecraft directory
```
df -h /home/minecraft
```

9- Now we will install the needed dependencies to run our Minecraft server
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

**Notice the error you got, this is because we need to accept the terms of the End User Licensing Agreement (EULA). We will edit the eula file. Change the** ```eula=false to eula=true```

```
sudo nano eula.txt
```

```
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui
```

Now the server is up and running. One issue though, is that our gaming session is tied to the current screen you're seeing now. If this screen is list for any reason, our session will be lost with it.

```
sudo apt-get install -y screen
```

```
sudo screen -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui
```

**Press press Ctrl+A, Ctrl+D to detach from the screen. To reattach the terminal, run the following command:** ```sudo screen -r mcs```

**Let's verify our gaming server. Go to this website and enter the extrnal IP address of your minecraft server here: https://mcsrvstat.us, If all went well, you will see something like this**

<img width="572" alt="Screenshot 2023-12-07 at 8 11 25 PM" src="https://github.com/a-elfateh/GCP/assets/61758821/e1892bb0-47ef-4fa1-b543-9d57f4673bbf">


```
gcloud compute instances add-metadata mine-server --zone=us-west1-c --metadata=startup-script-url=https://storage.googleapis.com/cloud-training/archinfra/mcserver/startup.sh
```

```
gcloud compute instances add-metadata mine-server --zone=us-west1-c --metadata=shutdown-script-url=https://storage.googleapis.com/cloud-training/archinfra/mcserver/shutdown.sh
```
