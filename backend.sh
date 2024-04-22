#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S) # 2024-04-21-07-00-14 -> Which time this is getting executed
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) # $0 -> to get the script name
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m" # red color symbol
G="\e[32m" # green color symbol
Y="\e[33m"
N="\e[0m"  # normal color symbol


VALIDATE(){
    if [ $1 -ne 0 ] # $1 have exit status of cmd : dnf install mysql -y
    then
        echo -e "$2...$R FAILURE $N" # -e for enabling colors $R for red $N for normal
        exit 1 # if FAILURE then only exit ortherwise no need to exit
    else
        echo -e "$2...$G SUCCESS $N"
    fi    
}


if [ $USERID -ne 0 ]
then
    echo "Please run this script with super user"
    exit 1 # manually exit if error comes
else
    echo "You are super user"
fi


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"


id expense &>>$LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi


mkdir -p /app  # -p if there is /app dierectory it skips otherwise it will create
VALIDATE $? "Creating app dierectory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend code"


cd /app
unzip /tmp/backend.zip
VALIDATE $? "Extracted backend code"

npm install
VALIDATE $? "Installing nodejs dependencies"

