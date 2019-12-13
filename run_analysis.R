# So we have to do this:

### You should create one R script called run_analysis.R that does the following.
### 
### 1) Merges the training and the test sets to create one data set.
### 2) Extracts only the measurements on the mean and standard deviation for each measurement.
### 3) Uses descriptive activity names to name the activities in the data set
### 4) Appropriately labels the data set with descriptive variable names.
### 5) From the data set in step 4, creates a second, independent tidy data set with the 
###   average of each variable for each activity and each subject.

## But first I download the data and unzip it somewhere:

library(data.table)
getwd()

setwd("I:/cursus/coursera/03_Getting and Cleading Data")

destfile <- "./week4/DatasetAssignment.zip"
outDir <- "./week4/DatasetAssignment"

urlie <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if(!dir.exists("week4")) {
        dir.create("week4")
    } 
    
download.file(urlie, destfile)
unzip(destfile, exdir=outDir)

# Having a look at the unzipped files with function 'list.files':

ZakenTotaal <- list.files(outDir, recursive = T)
print(ZakenTotaal)

# A lot of strange files with weird names! Let's make data.tables based on the relevant files. 
# I use data.tables instead of data.frames, because I am used to work with data.tables
# and I think data.tables are more cool too.

# 'activity' contains a number (1 to 6) and a description of the activity
# 'features' contains a number (1 to 561) and a description of the measurement

activity <- fread("week4/DatasetAssignment/UCI HAR Dataset/activity_labels.txt")
features <- fread("week4/DatasetAssignment/UCI HAR Dataset/features.txt")

# 'subject_train' and 'subject_test' contain subject numbers (1 to 30) with a lot of rows, 
# corresponding with the amount of rows in files spoken about very soon. 
# 'X_train' and 'X_test' contain the measurements of 561 variables (V1 to V561).
# 'Y_train' and 'Y_test' contain the activities (1 to 6). Later on these three type of files
# will be merged, so you got measurements attached to their corresponding subjects and activities: 

subject_train <- fread("week4/DatasetAssignment/UCI HAR Dataset/train/subject_train.txt")
X_train <- fread("week4/DatasetAssignment/UCI HAR Dataset/train/X_train.txt")
Y_train <- fread("week4/DatasetAssignment/UCI HAR Dataset/train/y_train.txt")

subject_test <- fread("week4/DatasetAssignment/UCI HAR Dataset/test/subject_test.txt")
X_test <- fread("week4/DatasetAssignment/UCI HAR Dataset/test/X_test.txt")
Y_test <- fread("week4/DatasetAssignment/UCI HAR Dataset/test/y_test.txt")

# Renaming variables since I don't like the ugly V1 and V2's. This is also step 4:
### 4) Appropriately labels the data set with descriptive variable names.

setnames(subject_train, "V1", "subject")
setnames(subject_test, "V1", "subject")
# A check to see if renaming worked. Function 'print' is not really necessary, but it may indicate more cleary
# that the goal is to perform a quick visual check:
print(subject_train)
print(subject_train[,.N, subject])

setnames(features, "V1", "feature_number")
setnames(features, "V2", "feature")
# A check to see if renaming worked:
names(features)
print(features)

setnames(activity, "V1", "activity_number")
setnames(activity, "V2", "activity")
# A check to see if renaming worked:
names(activity)
print(activity)

setnames(Y_train, "V1", "activity_number")
setnames(Y_test, "V1", "activity_number")
# A check to see if renaming worked:
names(Y_train)
print(Y_train)

# I saved the biggest rename operation for last. 'X_train' and 'Y_train' contain 561 ugly 
# column names (V1 to V561), these names will be replaced with the names in 'features', which 
# are names for the measurement variables. This is probably step 4 by the way:
### 4) Appropriately labels the data set with descriptive variable names.

names(X_train) <- features$feature
names(X_test) <- features$feature

# Now that the renaming is done (steps 3 and 4..) it is time for step 1:
### 1) Merges the training and the test sets to create one data set.

# I am not sure if this means to make 1 data set containing test as well as training sets, 
# or 1 merged set for training and one merged set for test. To be sure I will do both. 
# At first I merge the necessary files to create one training set and one test set separately, 
# at last I will merge the training set with the test set. 

# I start with the training set, after that is done I do copy paste work for the test set. 
# I create a table named 'Train_Total' after merging tables 'subject_train', 'Y_train', 'activity' and 'X_train'. 
# Further step 2 will be done as well, this selection: 

### 2) Extracts only the measurements on the mean and standard deviation for each measurement.

# It is possible to do this immediately when merging. 

# So.. lets go. First I merge 'Y_train' with 'activity', so you got the description of the activity at hand.

Y_train <- merge(Y_train, activity, all.x = T)
# just a check, counting activity and numbers:
Y_train[, .N, .(activity_number, activity)]

# Now I create a vector containing only the measurements on the mean and standard deviation for each measurement.
# The measurements are the column names in 'activity' and in 'X_train' as well.
# I will use this vector later as a way to select columns in the 'X-train' (and 'X_test') data.table:

VectorMeanSD <- grep('[Mm]ean|[Ss]td', names(X_train), value = T)
# This vector contains all column names with the text 'Mean', 'mean', 'Std' or 'std' in it. If you check the content 
# of the vector, you note that it also contains variables with 'meanFreq' in the name. If only variants like 
# 'mean()' and 'std()' are desired, then it is possible to get them this way:

# VectorMeanSD <- grep('[Mm]ean\\(\\)-|[Ss]td', names(X_train), value = T)

# Another little note, there is no need to include brackets for 'std', because all variants containing std 
# are like 'std()'. No variants like 'stdFreq' exists that you would like to exclude. 

# I was not sure what to do but after a lot of sleepless nights I finally decided 
# to be generous with my choice of vector. 

# A little check to check if this vector indeed contains only the column names I want:
names(X_train[,..VectorMeanSD])
# Only 86 columns to check so thats easily done!

# Now after all this babbling it is finally time to merge all stuff for training.
# I merge 3 tables into one. Subject_train contains the subject number, Y_train the activity and its number,
# X_train the measurements. VectorMeanSD makes sure only the wished measurements are returned. 

TrainTotal <- cbind(subject_train, Y_train, X_train[,..VectorMeanSD])
# And a visual check
print(TrainTotal)
# Another check, a summary about activities for each subject:
TrainTotal[,.N, .(subject, activity_number, activity)]


# Lets do the same for the test files!

Y_test <- merge(Y_test, activity, all.x = T)
Y_test[, .N, .(activity_number, activity)]
names(X_test) <- features$feature

TestTotal <- cbind(subject_test, Y_test, X_test[,..VectorMeanSD])
print(TestTotal)
TestTotal[,.N, .(subject, activity_number, activity)]

# I created two files, one for test and one for training. In order to avoid the risk of you 
# downgrading me, I merge these two files into one. 
# First I add an extra column to each file, hinting at their true origin: 

TrainTotal$condition <- 'train'
TestTotal$condition <- 'test'

# Now we can safely start our final merging operation:
Total <- rbind(TrainTotal, TestTotal)
# A quick check:
Total[,.N, condition]

# The last step:
### 5) From the data set in step 4, creates a second, independent tidy data set with the 
###   average of each variable for each activity and each subject.

# I give you three tidy data sets. One for the test data, one for the train data and one for
# the train and test data combined. Probably only the latter is asked for, but I don't want
# all my previous work to be in vain. 

# Tidy data set for test data:
Total[condition == "test", lapply(.SD, mean, na.rm=T), by = .(subject, activity_number, activity, condition), .SDcols = VectorMeanSD]

# Tidy data set for train data:
Total[condition == "train", lapply(.SD, mean, na.rm=T), by = .(subject, activity_number, activity, condition), .SDcols = VectorMeanSD]

# It is also possible to do it like this, one table containing the same information as the two tables
# for test and train apart:
# Total[, lapply(.SD, mean, na.rm=T), by = .(subject, activity_number, activity, condition), .SDcols = VectorMeanSD]
# I outcomment this, because I promised to give you only three tidy data sets.

# The third tidy data set:
# Test and train combined, origin of data (test or train) is ignored, just all stacked together. 

Total[, lapply(.SD, mean, na.rm=T), by = .(subject, activity_number, activity), .SDcols = VectorMeanSD]

# Let's write this one to a csv file to be uploaded to github:
write.csv2(Total[, lapply(.SD, mean, na.rm=T), by = .(subject, activity_number, activity), .SDcols = VectorMeanSD], "./week4/Output Assignment/AssignmentTidyDataset.csv", row.names=F)

# The scripting work is done now, unfortunately I still got to make an annoying codebook and README file. 
# For the moment I prefer to play a videogame, but not before I finish here with a last summary check that
# no one has asked for:

Total[,.N, .(condition, subject, activity_number, activity)]
Total[,.N, .(condition, subject, activity_number, activity)][,sum(N)]
nrow(Total)
