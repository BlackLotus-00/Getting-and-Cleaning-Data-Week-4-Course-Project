
library(data.table)
library(dplyr)


setwd("C:/Users/ashenfkt/Google Drive/Dashboard/R_April2017/PhoenixRising/Coursera")


URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
        download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
        unzip(destFile)
}
dateDownloaded <- date()


setwd("./UCI_HAR_Dataset")


ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)


FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)


SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)


ActivityLabels <- read.table("./activity_labels.txt", header = F)


FeaturesNames <- read.table("./features.txt", header = F)

FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)


names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")


Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]


names(SubjectData) <- "Subject"

names(FeaturesData) <- FeaturesNames$V2


DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)


subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)


names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))


SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]


write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)
