---
title: "README"
output: 
  html_document: 
    keep_md: yes
---



## 

My first step in attempting to complete the assignment ' Getting and Cleaning Data Course Project' was downloading and unzipping a bunch of files that I found here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Instead of performing clicking operations with my mouse, I used a script 'run_analysis.R' to do this job. Next step was identifying and 'importing' the necessary files in this script. 
Then some renaming of column names took place, as well as merging some files here and there and even some subselecting of measurements, resulting in one data set that contains only the measurements that have to do with means and standard deviations. 
Finally from this data set a tidy data set was created, with the average of each of the survived measurement/variabeles, for each activity and each subject. Or worded differently, the measurements where averaged grouped by the combination of subject and activity.  This tidy data set was exported as an output file named 'AssignmentTidyDataset.txt'.

I can imagine this README may not be detailed enough. Feel free to study my 'run_analysis.R' though, in which I tried to comment in detail on each step. 
