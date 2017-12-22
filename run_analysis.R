# You should create one R script called run_analysis.R that does the following.
# For melting data at end
library(reshape2)

# 0) Download and extract
directoryName = "UCI HAR Dataset"
if (!file.exists(directoryName)) {
  dataUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  dlFileZIP = "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataUrl, destfile = dlFileZIP)
  unzip(dlFileZIP)
}

# 1) Merges the training and the test sets to create one data set.

# Set file locations
activityLabelsLoc <- file.path(getwd(),directoryName,"activity_labels.txt")
featuresLoc       <- file.path(getwd(),directoryName,"features.txt")

trainXFileLoc <- file.path(getwd(),directoryName,"train","X_train.txt")
trainYFileLoc <- file.path(getwd(),directoryName,"train","Y_train.txt")

testXFileLoc <- file.path(getwd(),directoryName,"test","X_test.txt")
testYFileLoc <- file.path(getwd(),directoryName,"test","Y_test.txt")

subjectTrainLoc <- file.path(getwd(),directoryName,"train","subject_train.txt")
subjectTestLoc  <- file.path(getwd(),directoryName,"test","subject_test.txt")

# Read Files
featureTab <- read.table(featuresLoc, as.is = TRUE)
names(featureTab) <- c("FeatureID","FeatureName")

activitiesTab <- read.table(activityLabelsLoc)
# Label Activity
colnames(activitiesTab) <- c("ActivityID","ActivityName")

trainXTab <- read.table(trainXFileLoc)
testXTab <- read.table(testXFileLoc)

# Cleanup
rm(featureTab)

# Replace header IDs with measurements
names(trainXTab) <- featureTab$FeatureName
names(testXTab) <- featureTab$FeatureName

trainYTab <- read.table(trainYFileLoc)
testYTab <- read.table(testYFileLoc)

# Name activity to match activity label
names(trainYTab) <- "ActivityID"
names(testYTab) <- "ActivityID"

subjectTrain <- read.table(subjectTrainLoc)
subjectTest <- read.table(subjectTestLoc)
names(subjectTrain) <- "SubjectID"
names(subjectTest) <- "SubjectID"

# Merge Files
mergeTrain <- cbind(subjectTrain, trainYTab, trainXTab)
mergeTest <- cbind(subjectTest, testYTab, testXTab)

# Cleanup
rm(trainXTab,trainYTab,testXTab,testYTab,subjectTrain, subjectTest)
mergeAll <- rbind(mergeTrain, mergeTest)

# Cleanup
rm(mergeTrain, mergeTest)

# 2) Extracts only the measurements on the mean and standard deviation for each 
#     measurement.
meanStdCols <- grepl('MEAN|STD', toupper(names(featureTab)))
meanStdCols <- c(TRUE,TRUE, meanStdCols) # Keep first two cols (subject and activity)

mergeAllMeanStd <- mergeAll[, meanStdCols]

# Cleanup
rm(mergeAll)


# 3) Uses descriptive activity names to name the activities in the data set
mergeAllMeanStd$ActivityName <- factor(mergeAllMeanStd$ActivityID, 
                                       labels=activitiesTab$ActivityName, 
                                       levels=c(1,2,3,4,5,6))

# Cleanup
rm(activitiesTab)

# 4) Appropriately labels the data set with descriptive variable names.

# Previously done

# 5) From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject.
meltedData <- melt(mergeAllMeanStd, id=c("SubjectID","ActivityName"))
tidyData <- dcast(meltedData, SubjectID+ActivityName ~ variable, mean)

# Cleanup
rm(mergeAllMeanStd,meltedData)