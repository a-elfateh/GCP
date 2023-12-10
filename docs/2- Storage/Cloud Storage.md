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

```

```

```

```

```

```

```

```

```

```
