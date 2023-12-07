# Working with Google Cloud's Virtual Machines
In this tutioral, we will get to do get oud hands dirty with some of Google Cloud's Virtual Machines features from setting up a VM, customizing boot disks, cron jobs, startup/shudown scripts, utilizing reserved IP addresses, and finaly disk backups and snapshots.
# What's the plan exactly?
We will customize a virtual machine instance by installing base software, which's a headless Java runtime environment and application software, specifically, a **Minecraft game server 🛠️🧱💎** . Will customize the VM by preparing and attaching a high-speed SSD to match the game server's performance. 

We will also need a reserved a static external IP address; so we don't get bothered each time accessing the game by Google Cloud's ephermeral pool. We will take the IP and check the availability of the the gaming server on an outsource website.

We will set up a backing mechanisim by creating a Cloud Storage bucket, and backup up to it in a regural manner using cron jobs.

Finally, as most administrative roles require their personnel to automate some startup and shutdown tasks, we will take advantage of startup/shutdown scripts.


## Minecraft game server 🛠️🧱💎
