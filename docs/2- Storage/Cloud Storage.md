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

```

```
