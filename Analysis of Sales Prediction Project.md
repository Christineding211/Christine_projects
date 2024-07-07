## Analyse and predict Sales process:

### First train dataset

1. Check datatypes

2. View statistics get basic insights of Average and  maximum sales per day, Average and maximum number of customers

3. Check missing values : there is no missing values

4. Plot in histogram to Analyse the info: 

    A.  The Sales feature is right-skewed, This suggests that higher sales are less frequent, and the majority of sales are relatively low.
   
    B.  Customers feature is also right-skewed, indicating that most stores have a smaller number of customers on most days, with fewer stores of high customer counts.
   
    C.  The Promo feature shows promotions are not run on all days, but they are still quite frequent.
   
    D.  The SchoolHoliday feature shows that there are fewer school holidays than regular days in the dataset.

5. Focus only on the opened stores provides a more accurate picture of sales and customer trends and evaluate the impact of promotions on sales and customers

### Second store dataset

1. Check datatypes


2. View statistics get basic insights on average competition distances


3. Check missing values : Find the pattern of missing values (when 'promo2' is zero, 'promo2SinceWeek','Promo2SinceYear', and 'PromoInterval' information also set to zero as well), therefore fill these columns with 0. Additionally,there are 3 rows with missin values in 'Competition Distance'column, fill with average values.


4.  Plot in histogram to Analyse the info: 

   A.   CompetitionDistance: right-skewed distribution, indicating most stores have competitors located at a short distance (less than 10,000 meters)
  
   B.   CompetitionOpenSinceMonth: significant number of competitors opened in the earlier months of the year (particularly January)

   C.   There is a concentration of competitor openings and promotions  in the year 2000

### Merge the two clened dataset

1. Check again all the missing values have been handled


2. Since the target variable is 'sales'. Check the correlations of each variables with sales also plot with heatmap. (as we can see it make sense that the correlation between sales and customers are highly correlated)


3. Extract the year, month , and the day. Visualise the the average sales and customers per month, average sales and customers per day. and average sales and customers in the day of week.


4. Use LabelEncoder to convert categorical features into numerical


5. Compare Random Forest and Linear Regression in sales prediction, evaluated by MAE, RMSE,R2. The result shows that Random Forest have better performance in prediction.

