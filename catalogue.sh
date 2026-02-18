#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/c/DevOps/shell-roboshop "
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"


if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
     if [ $1 -ne 0 ]; then
        echo  -e "$2 ... $R failed" | tee -a $LOGS_FILE
        exit 1
     else 
        echo -e "$2 ....$G  Success" | tee -a $LOGS_FILE
    fi
}
 

 dnf module disable nodejs -y &>>LOGS_FILE
 VALIDATE $? "Disabling NodeJS Default version"

 dnf module enable nodejs:20 -y &>>LOGS_FILE
 VALIDATE $? "Enabling Nodejs 20"

 dnf install nodejs -y &>>LOGS_FILE
 VALIDATE $? "Install NodeJS"

 id roboshop &>>$LOGS_FILE
 if [ $? -ne 0]; then 

      useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOGS_FILE
      VALIDATE $? "Creating system user"
else 
      echo -e "Roboshop user already exists ... $Y SKIPPING $N"
fi

 mkdir -p /app
 VALIDATE $? "Creating app directory"

 curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>LOGS_FILE
 VALIDATE $? "Downloading catalogue code"  