# Getting and Cleaning Data Course Project Week 4
#


# 1. Get the data, create dir if not exist
#
if(!file.exists("./data"))
  {dir.create("./data")}
fUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fUrl,destfile="./data/Dataset.zip",method="curl")

# 2. Unzip the Dataset.zip
unzip(zipfile="./data/Dataset.zip",exdir="./data")

## 3. After unzip, data are under the directory of "UCI HAR Dataset", now working on this
my_data_path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(my_data_path, recursive=TRUE)

files  ## list files in the directory

## Read data and see the context

my_FeaturesTest  <- read.table(file.path(my_data_path, "test" , "X_test.txt" ),header = FALSE)
my_FeaturesTrain <- read.table(file.path(my_data_path, "train", "X_train.txt"),header = FALSE)
str(my_FeaturesTest)
str(my_FeaturesTrain)

my_SubjectTrain <- read.table(file.path(my_data_path, "train", "subject_train.txt"),header = FALSE)
my_SubjectTest  <- read.table(file.path(my_data_path, "test" , "subject_test.txt"),header = FALSE)
str(my_SubjectTrain)
str(my_SubjectTest)


my_ActivityTest  <- read.table(file.path(my_data_path, "test" , "Y_test.txt" ),header = FALSE)
my_ActivityTrain <- read.table(file.path(my_data_path, "train", "Y_train.txt"),header = FALSE)
str(my_ActivityTest)
str(my_ActivityTrain)

#####################################################
#
#
#  Merge Train and Test data and create a new one.
#
#
#####################################################


#### I.  Concatenate the data tables by rows

dataSubject <- rbind(my_SubjectTrain, my_SubjectTest)
dataActivity<- rbind(my_ActivityTrain, my_ActivityTest)
dataFeatures<- rbind(my_FeaturesTrain, my_FeaturesTest)

######  II  set names to variables

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(my_data_path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

########  III  Merge columns to get the data frame Data for all data

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


## Extracts only the measurements on the mean and standard deviation for each measurement
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)

## Uses descriptive activity names to name the activities in the data set
## Read descriptive activity via “activity_labels.txt”

activityLabels <- read.table(file.path(my_data_path, "activity_labels.txt"),header = FALSE)

## Apply label with descriptive name
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)<-gsub("^f", "Frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))


## Creates a second,independent tidy data set and ouput it
library(plyr);
DataSet2<-aggregate(. ~subject + activity, Data, mean)
DataSet2<-DataSet2[order(DataSet2$subject,DataSet2$activity),]
write.table(DataSet2, file = "tidy_data.txt",row.name=FALSE)


