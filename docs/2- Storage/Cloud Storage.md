```
gcloud storage buckets create gs://polonolo -l us-west1 --no-uniform-bucket-level-access --no-public-access-prevention
```

```
export bucket=YOUR_BUCKET_NAME
```

```
echo "Hello Cloud Storage" > sample.txt
```

```
cp sample.txt sample2.txt
cp sample.txt sample3.txt
```

```
gcloud storage cp sample.txt gs://$bucket
```

```
gsutil acl get gs://$bucket/sample.txt
```

```
gsutil acl set private gs://$bucket/sample.txt
```

```
gsutil acl get gs://$bucket/sample.txt
```

```
gsutil acl ch -u AllUsers:R gs://$bucket/sample.txt
```

**Examine the file in the Cloud Console on In the Cloud Console by accessing the Navigation Menu, click Cloud Storage > Buckets. Click you bucket name and then your object. Scroll down until seeing Public Url. Copy the URL and paste it in your browser**

# Customer-supplied encryption keys (CSEK)

```
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'
```

**Copy the value of the generated key excluding b' and \n' from the command output. Key should be in form of tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=**

```
gsutil config -n
```

```
nano .boto
```

**Locate the line with "#encryption_key="**

```
Before:
#encryption_key=

After:
encryption_key=tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=
```

```
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'
```

**Copy the value of the generated key excluding b' and \n' from the command output. Key should be in form of tmxElCaabWvJqR7uXEWQF39DhWTcDvChzuCmpHe6sb0=**

```
nano .boto
```

**Locate the line with "decryption_key1="**

```
Before:
#decryption_key1=

After:
decryption_key1=UUyZE5Fmj+2M3tw2LeEX4vwVoQ0/JmxSvii6gzbeToo=
```

```
gsutil cp sample2.txt gs://$bucket
gsutil cp sample3.txt gs://$bucket
```

**Examine the files in the Cloud Storage Console. Click you bucket name. You will get a list of all current sample.txt files. Move your cursor on top any of the 3 files, and hover to the right until reaching the "Encryption" column. You will see that the first file we uploaded before setting CSEK is "Google-managed", and the other two are " Customer-supplied"**

# Lifecycle Management

```
gsutil lifecycle get gs://$bucket
```

```
nano life.json
```

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

**Save the file using Ctrl+O and then CTRL+X to exit**

```
gsutil lifecycle set life.json gs://$bucket
```

```
gsutil lifecycle get gs://$bucket
```

# Object Versioning

```
gsutil versioning get gs://$bucket
```

```
gsutil versioning set on gs://$bucket
```

```
gsutil versioning get gs://$bucket
```

**Add another line to the sample.txt file so we can test versioning when re-uploading the file**

```
echo "Welcome to file Versioning" >> sample.txt
```

```
gsutil cp sample.txt gs://$bucket
```

```
rm sample.txt
```

```
gcloud storage ls -a gs://$bucket
```

**You will see that the sample.txt file has 2 versions now on top of each other. The second one is the new version of the file we just uploaded. Let's copy that one to our terminal and checkt it's content. Make sure in the next command to take the full name of the file to get the new version we just uploaded**

```
gsutil cp gs://$bucket/sample.txt#1702200588379369 .
```

```
cat sample.txt
```

