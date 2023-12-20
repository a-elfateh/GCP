# Cloud Storage

Cloud Storage is Google Cloud’s object storage service, and it's main feature is its worldwide availability of storing and retreving data at any time.

Here is some of Cloud Storage Use Cases:
- Website content
- Storing data for archiving and disaster recovery
- Distributing large data objects to users via direct download

# How does Cloud Storage actually works?
Some like to think of Cloud Storage as files in a file system but it’s not really a file system. Instead, Cloud Storage is a collection of buckets that you place objects into. You can create directories, so to speak, but really a directory is just another object that points to different objects in the bucket. You’re not going to easily be able to index all of these files like you would in a file system. You just have a specific URL to access objects

# When should I use Cloud Storage? 
1- When exabyte Scalablity is needed

2- When time to the first byte should be in millisecondes

3- High availability is a constrain

4- Useful for developing application; as it has a single API across all of it's storage classes

# Bucket Management
Let's look at Cloud Storage management in the Cloud Shell. Will be createing a Cloud Bucket and do some of it's basic operations on to it.

1- Let's first create a regional bucket in the us-west1 region
```
gcloud storage buckets create gs://BucketName -l us-west1 --no-uniform-bucket-level-access --no-public-access-prevention
```

2- Save your bucket name in a shell variable called "bucket"
```
export bucket=YOUR_BUCKET_NAM
```

3- Create a sample file for the next storage operations
```
echo "Hello Cloud Storage" > sample.txt
```

4- Create some extra copies of the file, will be needing them later.
```
cp sample.txt sample2.txt
cp sample.txt sample3.txt
```

5- Now copy your sample file to the cloud bucket
```
gcloud storage cp sample.txt gs://$bucket
```

6- List all the files in the bucket
```
gsutil ls gs://$bucket
```

7- You can also delete the file:
```
gsutil rm gs://$bucket/sample.txt
```

8- check if the file has been deleted
```
gsutil ls gs://$bucket
```

9- Now re-upload the file as we will be needing it in the next section
```
gsutil cp sample.txt gs://$bucket
```

# Access Control List (ACL)
- We can use IAM for the project to control which individual user or service account can see the bucket, list the objects in the bucket, view the names of the objects in the bucket, or create new buckets. For most purposes, IAM is sufficient, and roles are inherited from project to bucket to object.
- Access control lists or ACLs offer finer control.
- An ACL is a mechanism you can use to define who has access to your buckets and objects, as well as what level of access they have. The maximum number of ACL entries you can create for a bucket or object is 100. Each ACL consists of one or more entries, and these entries consist of two pieces of information:
  - A scope, which defines who can perform the specified actions (for example, a specific user or group of users).
  - And a permission, which defines what actions can be performed (for example, read or write).

1- Let's get the acl of our sample.txt file
```
gsutil acl get gs://$bucket/sample.txt
```

2- You can make a certain file in your bucket private
```
gsutil acl set private gs://$bucket/sample.txt
```

3- Now run the get command again and check the resulted output
```
gsutil acl get gs://$bucket/sample.txt
```

4- You can also make a file accessible for everyone on the internet through the "AllUsers" scope
```
gsutil acl ch -u AllUsers:R gs://$bucket/sample.txt
```

**Examine the file in the Cloud Console on In the Cloud Console by accessing the Navigation Menu, click Cloud Storage > Buckets. Click you bucket name and then your object. Scroll down until seeing Public Url. Copy the URL and paste it in your browser**

# Customer-supplied encryption keys (CSEK)
An additional layer of security on top of the Google-Manage Encryption Keys. You can provide your own AES-256 encryption key, encoded in standard Base64. This key is known as a customer-supplied encryption key.

1- Let's first generate an encryption key, that Cloud Storage will use for encrypting files
```
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'
```

**Copy the value of the generated key excluding b' and \n' from the command output. Key should be in form of tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=**

2- Generate the configuration file that cloud storage uses and use the ```nano``` editor to edit the file
```
gsutil config -n
nano .boto
```

**Locate the line with "#encryption_key=" the file before editing it, and after editing it should look like this**

```
Before:
#encryption_key=

After:
encryption_key=tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=
```

3- Now let's redo the same steps, but for a decryption key.

```
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'
```

**Copy the value of the generated key excluding b' and \n' from the command output. Key should be in form of tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=**

```
nano .boto
```

**Locate the line with "decryption_key1=", the file before editing it, and after editing it should look like this**

```
Before:
#decryption_key1=

After:
decryption_key1=UUyZE5Fmj+2M3tw2LeEX4vwVoQ0/JmxSvii6gzbeToo=
```

4- Now let's test our keys, upload the 2 versions we cerated earlier to Cloud Storage 
```
gsutil cp sample2.txt gs://$bucket
gsutil cp sample3.txt gs://$bucket
```

**Examine the files in the Cloud Storage Console. Click you bucket name. You will get a list of all current sample.txt files. Move your cursor on top any of the 3 files, and hover to the right until reaching the "Encryption" column. You will see that the first file we uploaded before setting CSEK is "Google-managed", and the other two are " Customer-supplied"**

# Lifecycle Management

To support common use cases like setting a Time to Live for objects, archiving older versions of objects, or "downgrading" storage classes of objects to help manage costs, Cloud Storage offers Object Lifecycle Management. You can assign a lifecycle management configuration to a bucket. The configuration is a set of rules that apply to all the objects in the bucket. So when an object meets the criteria of one of the rules, Cloud Storage automatically performs a specified action on the object.

1- Let's check if any configuration is set on our bucket
```
gsutil lifecycle get gs://$bucket
```

2- Create a lifecycle management file, copy the below text and paste it in the ```life.json``` file 
```
{
  "rule":
  [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 31}
    }
  ]
}
```

```
nano life.json
```

**Paste the code, save the file using Ctrl+O ,and then CTRL+X to exit**

3- Apply the lifecycle policy using this command
```
gsutil lifecycle set life.json gs://$bucket
```

4- Now run the get command again to check the lifecycle policy on your bucket
```
gsutil lifecycle get gs://$bucket
```

# Object Versioning
In Cloud Storage, objects are immutable, which means that an uploaded object cannot change throughout its storage lifetime. To support the retrieval of objects that are deleted or overwritten, Cloud Storage offers the Object Versioning feature. 

Object Versioning can be enabled for a bucket. Once enabled, Cloud Storage creates an archived version of an object each time the live version of the object is overwritten or deleted. The archived version retains the name of the object but is uniquely identified by a generation number which you'll get to see.

1- Run the get command to view the current versioning policy 
```
gsutil versioning get gs://$bucket
```

2- Enable versioning on your bucket 
```
gsutil versioning set on gs://$bucket
```

3- Re-run the get command and examine the output
```
gsutil versioning get gs://$bucket
```

**Add another line to the sample.txt file so we can test versioning when re-uploading the file**

```
echo "Welcome to file Versioning" >> sample.txt && gsutil cp sample.txt gs://$bucket
```

4- Delete the currne local ```sample.txt``` from your cloud shell environment.
```
rm sample.txt
```

5- Now do a detailed listing on your bucket to view all objects and any versions if available.
```
gcloud storage ls -a gs://$bucket
```

**You will see that the sample.txt file has 2 versions now on top of each other. The second one is the new version of the file we just uploaded. Let's copy that one to our terminal and checkt it's content. Make sure in the next command to take the full name of the file to get the new version we just uploaded**

```
gsutil cp gs://$bucket/sample.txt#1702200588379369 .
```

6- Check the content of your local ```sample.txt``` file you just copied from your bucket to guarantee your work.
```
cat sample.txt
```

