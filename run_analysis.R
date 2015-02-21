# Script name: "run_analysis.R"
# Author: Richard Badham
# Date: 2015.02.21
# Coursera Getting and Cleaning Data course
 
# The data linked below represents data collected from the accelerometers from the Samsung Galaxy S 
# A full description is available at the site where the data was obtained: 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

# Here are the data for the project: 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# Create one R script called run_analysis.R that does the following. 
# 1). Merges the training and the test sets to create one data set.
# 2). Extract only the measurements on the mean and standard deviation for each measurement.
# 3). Uses descriptive activity names to name the activities in the data set
# 4). Appropriately labels the data set with descriptive variable names.
# 5). From the data set in step 4, create a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

# Check to see if data directory exists, if not, assume we are in it.
dataDir <- "UCI HAR Dataset"
if (file.exists(dataDir)){
	setwd(dataDir)
}

# Read the activity labels
activity_labels <- read.table("./activity_labels.txt")

# Rename columns
colnames(activity_labels) <- c("activity_id", "activity")

# Read the feature labels
features <- read.table("./features.txt") # 561 x 2

# Read the training data  
X_train <- read.table("./train/X_train.txt")  # 7352 x 561

# Replace training data column labels with feature labels
colnames(X_train) <- features[,2] 

# Read the training activity index column
y_train <- read.table("./train/y_train.txt") # 7352 x 1 activity label index

# Replace activity index column name
colnames(y_train) <- "activity_id"

# Merge the activity code column into the training data
merged_training_data <- cbind(y_train, X_train, deparse.level = 0 )

# Remove unnecessary data from memory
rm(X_train); rm(y_train)


# Read in the test data  
X_test <- read.table("./test/X_test.txt")  # 7352 x 561

# Replace test data column names with feature labels
colnames(X_test) <- features[,2] 

# Read in the testing activity index column
y_test <- read.table("./test/y_test.txt") # 7352 x 1 activity label index

# Replace activity index column name
colnames(y_test) <- "activity_id"

# Merge the activity code column into the testing data
merged_test_data <- cbind(y_test, X_test, deparse.level = 0 )

#Combine the two sets of data using row binding function
combined_training_and_test_data <- rbind(merged_training_data, merged_test_data, deparse.level = 0 )

# Merge in the activity labels
dataset_with_activity_labels <- merge(activity_labels, combined_training_and_test_data, by = "activity_id")

# Get the column names, filter for mean() and std(), then add in the "activity" column 
column_names <- colnames(dataset_with_activity_labels)
cols <- c("activity",column_names[sort(c(grep("mean()",fixed=T , column_names), grep("std()", fixed=T , column_names)))])

# Make a clean dataset with just the columns we want
mean_and_std <- dataset_with_activity_labels[,cols]

# Aggregate data by activities
tidy_dataset <- aggregate(mean_and_std [,c(-1,-2)], by=list(mean_and_std $activity), FUN=mean)

# Rename the group column
colnames(tidy_dataset)[1] <- "Activity"

# Write the resulting data to disk.
write.table(tidy_dataset, file="tidy_dataset.txt", row.names=FALSE)
