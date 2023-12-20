# Analyzing billing data with BigQuery
Google Cloud has made it really easy for you to analyze your expenditure by exporting your billing data through a CSV file, and the second part that Google has eased for their customers is that you can load all of this data in a matter of single clicks or ```gcloud``` commands. 

BigQuery is a great choice for analyzing your billing data where you can run your queries against your data. Having this data in BigQuery also makes it much easier to integrate with other tools, like Looker or Data Studio for visualization.

The data exported from your billing account are hourly rates of the services under that billing account. 

This analysis helps in tracking and understanding how are your resources contribute to your enitre spenditure across all of your projects. It helps in ensuring that your costs are being spent efficently and to plan well for future costs.

# Someone might wonder: Why use BigQuery for this task?
A valid question; as there are other SQL alternatives such as running an SQL virtual machine, or using Cloud SQL. BigQuery is suited for this kind of work. It's build for large scaled data-sets that are rapidly growing (and monthly billing consumption is diffently that). You can also integrate BigQuery with Looker to have your billing data in a visualized manner, or integrate it with other machine learining services for future insights.

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
    export-billing-example.csv
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

7- Let's try on query in the shell environement, enter the BigQuery shell
```
bq shell
```

8- Run the following query to get all serivces that had no cost in that month of billing
```
SELECT * FROM imported_billing_data.sampleinfotable WHERE Cost = 0
```
**Switching to the BigQuery console**

