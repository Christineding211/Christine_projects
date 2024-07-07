library(dplyr) 
library(ggplot2)
install.packages("dplyr")

covid<- read.csv('owid-covid-data.csv')
View(covid)
colnames(covid)

#choose the country and choose the column

selected_countries<- 'United States'

US_covid<- covid %>%
  dplyr::select(location,date,new_cases_smoothed,new_deaths_smoothed,icu_patients,weekly_hosp_admissions)%>%
  filter(location %in% selected_countries, covid$date>= '2020-12-01' & covid$date<= '2022-12-31')

View(US_covid)

#Checking for Missing Values 
US_covid_filter<- subset(US_covid, !(is.na(new_cases_smoothed) | new_cases_smoothed == 0) & !(is.na(new_deaths_smoothed) | new_deaths_smoothed == 0) & 
                           !(is.na(icu_patients) |icu_patients==0) & !(is.na(weekly_hosp_admissions) | weekly_hosp_admissions==0))
View(US_covid_filter)

#checking for outliers 
Q1 <- quantile(US_covid_filter$new_cases_smoothed, 0.25)
Q3 <- quantile(US_covid_filter$new_cases_smoothed, 0.75)
IQR_value <- Q3 - Q1

lower_bound <- Q1 - 1.5 * IQR_value
upper_bound <- Q3 + 1.5 * IQR_value

# Find outliers from cases column
cases_outliers <- US_covid_filter$new_cases_smoothed[US_covid_filter$new_cases_smoothed < lower_bound | US_covid_filter$new_cases_smoothed> upper_bound]

# Print the outliers
print(cases_outliers)

# Remove outliers from the original data frame
US_covid_filter_clean <- US_covid_filter[!(US_covid_filter$new_cases_smoothed %in% cases_outliers), ]
dim(US_covid_filter_clean)
View(US_covid_filter_clean) #714


# Find outliers from weekly hospital admissions column
Q1.1<- quantile(US_covid_filter_clean$weekly_hosp_admissions, 0.25)
Q3.1<- quantile(US_covid_filter_clean$weekly_hosp_admissions, 0.75)
IQR_value_1 <- Q3.1-Q1.1
print(IQR_value_1)
lower_bound.1 <- Q1.1 - 1.5 * IQR_value_1
upper_bound.1 <- Q3.1 + 1.5 * IQR_value_1

#find and remove the outliers in weekly hospital admissions column
hos_outliers<-US_covid_filter_clean$weekly_hosp_admissions[US_covid_filter_clean$weekly_hosp_admissions<lower_bound.1 | US_covid_filter_clean$weekly_hosp_admissions >upper_bound.1]
print(hos_outliers)

US_covid_filter_clean_2 <- US_covid_filter_clean[!(US_covid_filter_clean$weekly_hosp_admissions %in% hos_outliers), ]
rownames(US_covid_filter_clean_2) <- NULL
View(US_covid_filter_clean_2) #659 rows


# Create a new data frame without the date and region variable
US_covid_filter_cleaned_3 <- US_covid_filter_clean_2[, c("date","new_cases_smoothed", "new_deaths_smoothed", "icu_patients","weekly_hosp_admissions")]
names(US_covid_filter_cleaned_3 ) <- c("date","cases", "deaths", "icu","weekly_hos")
View(US_covid_filter_cleaned_3)



US_covid_filter_cleaned_3$date<- as.Date(US_covid_filter_cleaned_3$date)

#plot the cases, icu patients, Weekly Hospital Admissions based on date
ggplot(US_covid_filter_cleaned_3, aes(x = date)) +
  geom_line(aes(y= cases,color = "Cases")) + 
  geom_line(aes(y = deaths, color = "Deaths")) +
  geom_line(aes(y = icu, color = "ICU patients")) +
  geom_line(aes(y = weekly_hos, color = "Weekly Hospital Admissions")) +
  labs(x = "Date", y = "Count", color = "Legend",caption = 'Our world in Data') +
  scale_color_manual(values = c("Cases"="orange","Deaths" = "red", "ICU patients" = "blue", "Weekly Hospital Admissions" = "green")) +
  theme_minimal()


#correlation
# first step is to split the data into training and testing data
#total 659 rows

us_covid_train <- US_covid_filter_cleaned_3[1:520,]
us_covid_test <- US_covid_filter_cleaned_3[521:659,]
summary(us_covid_train)

#plot the scatterplot to see the relationship between cases and deaths
ggplot(
  data = us_covid_train,
  aes(x = cases , y = deaths)
) + geom_point()+
  labs(title = "Scatterplot of Daily Cases and Mortality Rates",caption = 'Our World in Data')

#plot the scatterplot to see the relationship between icu and deaths
ggplot(
  data = us_covid_train,
  aes(x = icu , y = deaths)
) + geom_point()+
  labs(title = "Scatterplot of ICU patients and Mortality Rates",caption = 'Our World in Data')


#plot the scatterplot to see the relationship between weekly admission and deaths
ggplot(
  data = us_covid_train,
  aes(x = weekly_hos , y = deaths)
) + geom_point()+
  labs(title = "Scatterplot of Weekly hospital admission and Mortality Rates",caption = 'Our World in Data')

# see the correlation between three vsriables and deaths 

set.seed(123)
cor.test(us_covid_train$cases,
         us_covid_train$deaths) #0.4716574 

cor.test(us_covid_train$icu,
         us_covid_train$deaths) #0.7181053

cor.test(us_covid_train$weekly_hos,
         us_covid_train$deaths) #0.6258599 


#train the models predict the death use cases + icu admission

mod_cases<-lm(
  formula = deaths~cases + icu, 
  data = us_covid_train
)
summary(mod_cases)

#train the models predict the death use cases + weekly hospital admission

mod_hos<-lm(
  formula = deaths~cases + weekly_hos, 
  data = us_covid_train
)
summary(mod_hos)

#train the models predict the death use icu + weekly hospital admission

mod_icu<-lm(
  formula = deaths~icu + weekly_hos, 
  data = us_covid_train
)
summary(mod_icu)

#checking for multicollinearity
library(car)
vif(mod_cases)
vif(mod_hos)
vif(mod_icu)


# compare the model using cross-validation

install.packages("lattice")
library(lattice)
library(caret)

# Define the number of folds for cross-validation
k <- 5

# Cross-validation for mod_cases
ctrl <- trainControl(method = "cv", number = k)

# Define the formula for Model 1
formula1 <- deaths ~ cases + icu
model1 <- train(formula1,
                data = us_covid_train,
                method = "lm",  
                trControl = ctrl)

# Define the formula for Model 2
formula2 <- deaths ~ cases + weekly_hos
model2 <- train(formula2,
                data = us_covid_train,
                method = "lm",  
                trControl = ctrl)

# Define the formula for Model 3
formula3 <- deaths ~ icu + weekly_hos
model3 <- train(formula3,
                data = us_covid_train,
                method = "lm",  
                trControl = ctrl)

results <- resamples(list(Model1 = model1, Model2 = model2, Model3 = model3))

# Summarize the results
summary(results)

#after compareing left two model
#deaths ~ cases + icu
#deaths~ icu + weekly

#plot the relationship between cases and icu two independent variables
ggplot(data = us_covid_train,
       aes(x = cases, y = icu)) + geom_point()+
  geom_smooth(method = 'lm',se = FALSE) +
  labs(x='New Cases daily', y='icu patients', title='Model1:Relation between New Cases & icu patients ',                                       
       caption ='Our world in data')

#plot the relationship between icu and weekly hospital admission
ggplot(data = us_covid_train,
       aes(x = weekly_hos, y = icu)) + geom_point()+
  geom_smooth(method = 'lm',se = FALSE) +
  labs(x='Weekly hospital admission', y='icu patients', title='Model3:Relation between weekly hospital admission & icu patients',
       caption ='Our world in data')



#predict the deaths (death ~ cases + icu)

predict(
  mod_cases,
  newdata = us_covid_test
)

predict(
  mod_cases,
  newdata = us_covid_test,
  interval='confidence'
)

us_cases_test <- us_covid_test 
us_cases_test$prediction <- predict(mod_cases, newdata = us_cases_test, type = "response")
us_cases_test$residuals<- us_cases_test$prediction - us_cases_test$deaths
View(us_cases_test)

summary(us_cases_test)

SSE_cases <- sum(us_cases_test$residuals**2)
SSE_cases #2644650

#predict the deaths (death ~ icu + weekly admission)
predict(
  mod_icu,
  newdata = us_covid_test
)

predict(
  mod_icu,
  newdata = us_covid_test,
  interval='confidence'
)

us_icu_test <- us_covid_test 
us_icu_test$prediction <- predict(mod_icu, newdata = us_icu_test, type = "response")
us_icu_test$residuals<- us_icu_test$prediction - us_icu_test$deaths
View(us_icu_test)

summary(us_icu_test)

SSE_icu <- sum(us_icu_test$residuals**2)
SSE_icu #1486865


# Combine the actual deaths, us_icu_test$prediction, and us_cases_test$prediction
plot_data <- data.frame(
  Date = us_icu_test$date, 
  Actual_Deaths = us_icu_test$deaths,
  ICU_Predicted_Deaths = us_icu_test$prediction,
  Cases_Predicted_Deaths = us_cases_test$prediction
)

# Create the plot of autual and predicted death prove that icu+ weekly admissions variables are  more accuracy 
ggplot(plot_data, aes(x = Date)) +
  geom_line(aes(y = Actual_Deaths, color = "Actual Deaths")) +
  geom_line(aes(y = ICU_Predicted_Deaths, color = "ICU Predicted Deaths")) +
  geom_line(aes(y = Cases_Predicted_Deaths, color = "Cases Predicted Deaths")) +
  labs(x = "Date", y = "Deaths", color = "Legend", title = "Comparison of Actual Deaths and Predicted Deaths",caption ='Our world in data') +
  scale_color_manual(values = c("Actual Deaths" = "red", "ICU Predicted Deaths" = "blue", "Cases Predicted Deaths" = "green")) 
  
