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


dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/

