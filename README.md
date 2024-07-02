## Goal: Analysis of Financial Customer Segments 

### Data Analysis Process:
1. Read/load the data

2. Check datatypes (numerical & Categorical)

3. Check the transactions have to be non-negative values

4. View the Statistics of the dataset : Mean of balance,Purchases average, one off purchase average, purchases frequency, and Average tenure

5. Handling missing values : Since the Distribution of CREDIT_LIMIT & MINIMUM_PAYMENTS are highly right skewed, the median would be a more robust measure for imputation.

6. Drop irrelevant column (CUST_ID)

7. Features selection: used corr() correlation function and heatmap to view the features correlation and detect Potential Multicollinearity

8. Normalise the scale : since different attributes have different scales, if calculate together for distance, the number with bigger will contribute most in distance and lead to the bias result. Therefore, need to normalise the data into same scale

9. K-menas cluster : clustering the customer into segmentation by using elbow method to determine the number of k. And also use silhouette_score to testing that k = 3 is the better clustering

10. Examine the Cluster Centers: creates a DataFrame from the cluster centers obtained from the K-Means model, and check "average" data point for each cluster. This can help understand the characteristics of each cluster.

11. Assign the cluster to original dataset to check the shape, max and min to make sure proper cluster

12. Apply PCA for dimensional reduction to transform largerdataset features into smaller while retaining original variability in data. The reason why need to do this :

  - visualisation : provide the insights of cluster separated in 2D plot
  - noise reduction : remove noise and redundant features
  - computational efficiency : make cluster more faster and efficient

## Business Insights from clustering customers:
### Cluster 0:
Customers have a relatively low balance, use more frequently than other clusters in cash advances. With low purchase activity and High tenure. This might be a long-term customer who prefer using cash advances over making purchases.

### Cluster 1: 
Moderate balance, low cash advances. Make purchases frequently but with smaller amounts and prefer to make purchases in instalments. These customers are frequent shoppers who prefer to spread their payments over time and rarely use cash advances.

### Cluster 2: 
Highest balance with highest credit limit makes high-value purchases. In addition, they tend to pay their balance in full. These can be seeming as high-value customers.

## Business Strategies :
### Cluster 0: Offer incentives for making more purchases. Encourage the use of other financial products besides cash advances.

### Cluster 1: Offer promotions or discounts to increase spending. Provide personalized recommendations and rewards for frequent purchases.

### Cluster 2: Offer premium services and Introduce high-end financial products to retain these high-value customers.
