if(!file.exists("./DataProject")){dir.create("./DataProject")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./DataProject/Data.zip ")
unzip(zipfile = "./DataProject/Data.zip", exdir = "./DataProject")
path_data <- file.path("./DataProject", "UCI HAR Dataset")


activityTestData  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),
                                header = FALSE)
activityTrainData <- read.table(file.path(path_data, "train", "Y_train.txt"),
                                header = FALSE)

subjectTrainData <- read.table(file.path(path_data, "train", "subject_train.txt"),
                               header = FALSE)
subjectTestData  <- read.table(file.path(path_data, "test" , "subject_test.txt"),
                               header = FALSE)

featuresTestData  <- read.table(file.path(path_data, "test" , "X_test.txt" ),
                                header = FALSE)
featuresTrainData <- read.table(file.path(path_data, "train", "X_train.txt"),
                                header = FALSE)

subject <- rbind(subjectTestData, subjectTrainData)

activity <- rbind(activityTrainData, activityTestData)

features <- rbind(featuresTrainData, featuresTestData)

Featurenames <- read.table(file.path(path_data, "features.txt"), header = FALSE)

names(features) <- Featurenames$V2


names(activity) <- c("Activity")
names(subject) <- c("Subject")
DATAComb <- cbind(subject, activity)
DATA <- cbind(features, DATAComb)

columnwithmeansd <- Featurenames$V2[grep("mean\\(\\)|std\\(\\)", 
                                         Featurenames$V2)]

selectednames <- c(as.character(columnwithmeansd), "Subject", "Activity")

DATA <- subset(DATA, select = selectednames)

activitylabels <- read.table(file.path(path_data, "activity_labels.txt"), 
                             header = FALSE)

DATA$Activity <- as.character(DATA$Activity)

for (i in 1:6){DATA$Activity[DATA$Activity==i] <- as.character(activitylabels[i,2])}


names(DATA) <- gsub("^t", "time", names(DATA))
names(DATA) <- gsub("^f", "frequency", names(DATA))
names(DATA) <- gsub("^Acc", "Accelerometer", names(DATA))
names(DATA) <- gsub("^Gyro", "Gyroscope", names(DATA))
names(DATA) <- gsub("^Mag", "Magnitude", names(DATA))
names(DATA) <- gsub("^BodyBody", "Body", names(DATA))
names(DATA)

library(plyr)
DataAgre <- aggregate(.~Subject + Activity, DATA, mean)
DataAgre <- DataAgre[order(DataAgre$Subject, DataAgre$Activity),]
write.table(DataAgre, file = "tinydata.txt", row.names = FALSE)

library(knitr)
knit2html("Codebook.Rmd", output = "DataProject/Codebook.md")


