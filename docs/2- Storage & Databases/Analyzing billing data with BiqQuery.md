# Analyzing billing data with BigQuery
Google Cloud has made it really easy to analyze your expenditure by exporting your billing data and loading it for analysis on BigQuery, in a matter of single console clicks or ```gcloud``` commands. 

BigQuery is a great choice for analyzing your billing data where you can run your queries. The data exported from your billing account are hourly rates of the services under that billing account. Having this data in BigQuery also makes it much easier to integrate with other tools, like Looker or Data Studio for visualization.

This analysis helps in tracking and understanding how your resources contribute to your entire expenditure across all of your projects. It helps in ensuring that your costs are being spent efficiently and to plan well for future costs.

# Someone might wonder, why use BigQuery for this task specifically?
A valid question; as there are other SQL alternatives such as running an SQL virtual machine, or using Cloud SQL. BigQuery is suited for this kind of work. It's build for large scaled data-sets that are rapidly growing (and a monthly cloud billing consumption is diffently so). You can also integrate BigQuery with Looker to have your billing data in a visualized manner, or integrate it with other machine laerning services for future insights.

# Tutorial
In this walk-throug we will complete our tasks using both the cloud shell and the console to achieve the following:
- Create a dataset and a table
- Import data from a billing CSV file stored in a bucket
- Run complex queries on a larger dataset


1- Fire up your cloud shell enviornment, we will create a dataset called "imported_billing_data"
```
bq mk --location us --dataset_id imported_billing_data --default_table_expiration 3600
```

2- Pull the sample csv billing data that we will be working on
```
wget https://github.com/a-elfateh/GCP/blob/main/resources/export-billing-example.csv
```

3- Create a table in the "imported_billing_data" dataset called "sampleinfotable" using the csv you just pulled
```
bq load \
--autodetect \
--source_format=CSV \
imported_billing_data.sampleinfotable \
gs://cloud-training/archinfra/export-billing-example.csv
```

4- Now let's check that the data has been ingested successfully through the ```show``` command
```
bq show --format=prettyjson :imported_billing_data
```

5- Get the details of the "sampleinfotable" table 
```
bq show --format=prettyjson :imported_billing_data.sampleinfotable 
```

6- Run the following command, you should see that the number of rows of the "sampleinfotable" is 44
```
bq show --format=prettyjson :imported_billing_data.sampleinfotable | grep numRows
```

**Moving forward is the query part, you have 2 methods, the ```bq shell``` in the cloud shell (I really don't recommend this one; as database queries in shells are not well presented, especially if the number of columns is big which is the case here). The second way is the BigQuery console which is a beautiful interface which we will use moving forward.**

7- Let's try to query in the shell environement, enter the BigQuery shell
```
bq shell
```

8- Run the following query to get all serivces that had no cost in that month of billing
```
SELECT * FROM imported_billing_data.sampleinfotable WHERE Cost = 0
```
**Switching to the BigQuery console, from the navigation menu in the top left side, enter the BigQuery console. There you will see all the datasets that you created**

1- Expand the ```imported_billing_data``` dataset to view the tables associated with it, from there you will get to see the ```sampleinfotable``` we created using the shell. Click on the ```sampleinfotable```

![Screenshot 2023-12-11 at 9 13 05 AM](https://github.com/a-elfateh/GCP/assets/61758821/8ca27e9d-7c3b-477f-b974-0ba3e2273d8f)


2- Click on "DETAILS" to view the details of the ```sampleinfotable``` table. **Note that the "Table expiration" and the "Data location" is equal to what we did in the shell earlier**

![Screenshot 2023-12-11 at 9 12 56 AM](https://github.com/a-elfateh/GCP/assets/61758821/c8ead1f4-f8ae-4c66-8b9f-c8674a2e7036)

3- Click on the plus sign next to the ```sampleinfotable``` opened tab to run some quiers on our dataset. Copy and paste the following query to view services that had 0 charges. Press the blue button "Run" to run your query
```
SELECT * FROM `imported_billing_data.sampleinfotable`
WHERE Cost > 0
```

**We will work now on a large public dataset constructing of over 20000 lines, made available by Google Cloud for experimental use cases such as our lab**

4- On the query tab, paste the following in query editor to view the entire dataset
```
SELECT
  product,
  resource_type,
  start_time,
  end_time,
  cost,
  project_id,
  project_name,
  project_labels_key,
  currency,
  currency_conversion_rate,
  usage_amount,
  usage_unit
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
```

![Screenshot 2023-12-11 at 9 13 40 AM](https://github.com/a-elfateh/GCP/assets/61758821/50943f6c-a136-4a57-a3ed-b48fe0175cd7)

**The output should look something like this**

![Screenshot 2023-12-11 at 9 13 52 AM](https://github.com/a-elfateh/GCP/assets/61758821/cc2cec32-e41a-4baa-a3bc-e9ad341847cf)

5- Now run the following query to find the latest 100 records where there were charges (cost > 0)
```
SELECT
  product,
  resource_type,
  start_time,
  end_time,
  cost,
  project_id,
  project_name,
  project_labels_key,
  currency,
  currency_conversion_rate,
  usage_amount,
  usage_unit
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
WHERE
  Cost > 0
ORDER BY end_time DESC
LIMIT
  100
```

6- After, run this query to find all charges that were more than 3 dollars
```
SELECT
  product,
  resource_type,
  start_time,
  end_time,
  cost,
  project_id,
  project_name,
  project_labels_key,
  currency,
  currency_conversion_rate,
  usage_amount,
  usage_unit
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
WHERE
  cost > 3
```

7- Let's try to get the product with the most records in the billing data
```
SELECT
  product,
  COUNT(*) AS billing_records
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
GROUP BY
  product
ORDER BY billing_records DESC
```

8- Get the most frequently used product costing more than 1 dollar using this query
```
SELECT
  product,
  COUNT(*) AS billing_records
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
WHERE
  cost > 1
GROUP BY
  product
ORDER BY
  billing_records DESC
```
9- Finally, let's try to find the product with the highest aggregate cost
```
SELECT
  product,
  ROUND(SUM(cost),2) AS total_cost
FROM
  `cloud-training-prod-bucket.arch_infra.billing_data`
GROUP BY
  product
ORDER BY
  total_cost DESC
```
