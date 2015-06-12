# Merge training and test data

#Load
train = read.table("./train/X_train.txt")
trainlab = read.table("./train/y_train.txt")

test = read.table("./test/X_test.txt")
testlab = read.table("./test/y_test.txt")

#nrow(train) = 7352, nrow(test) = 2947

#Merge 
dataset = rbind(train,test)


# Extracts only the measurements on the mean and standard deviation for each measurement
feat = read.table("features.txt")
indices = grep("mean\\(\\)|std\\(\\)",feat$V2)

dataset = dataset[,indices]
featnames = gsub("mean\\(\\)","Mean",feat$V2[indices])
featnames = gsub("std\\(\\)", "Stdev", featnames)
featnames = gsub("-","_",featnames)

# Uses descriptive activity names to name the activities in the data set
activity = read.table("activity_labels.txt")
dataset = cbind(dataset,rbind(trainlab,testlab))
# Remove duplicate column names
names(dataset)[67] = "Labels"
dataset = merge(dataset,activity,by.x="Labels",by.y="V1",all.x=TRUE)

# Appropriately labels the data set with descriptive variable names
names(dataset)[3] = "V2"
dataset$Labels=NULL

# Get column names of dataset from features.txt
# names(dataset) = feat[as.numeric(substr(names(dataset)[1:66],2,100))]
names(dataset) = featnames
names(dataset)[67]="Labels"

# Create a second, independent tidy data set with the average of each variable for each activity and each subject

# Load Subject info
subtrain = read.table("./train/subject_train.txt")
subtest = read.table("./test/subject_test.txt")

dataset = cbind(dataset,rbind(subtrain, subtest))
names(dataset)[68] = "Subject"

library(dplyr)
submission = dataset %>% group_by(Subject,Labels) %>% summarise_each(funs(mean))

write.table(submission,"tidy_means.txt",row.name=FALSE)


