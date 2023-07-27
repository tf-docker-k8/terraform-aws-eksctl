#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG=/tmp/docker-install.log
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
	echo  -e "$R You are not the root user, you dont have permissions to run this $N"
	exit 1
fi

VALIDATE(){
	if [ $1 -ne 0 ]; then
		echo -e "$2 ... $R FAILED $N"
		exit 1
	else
		echo -e "$2 ... $G SUCCESS $N"
	fi

}

yum update  -y &>>$LOG
VALIDATE $? "Updating packages"

amazon-linux-extras install docker -y &>>$LOG
VALIDATE $? "Installing Docker"

service docker start &>>$LOG
VALIDATE $? "Starting Docker"

systemctl enable docker &>>$LOG
VALIDATE $? "Enabling Docker"

usermod -a -G docker ec2-user &>>$LOG
VALIDATE $? "Added ec2-user to docker group"

yum install git -y &>>$LOG
VALIDATE $? "Installing GIT"

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose &>>$LOG
VALIDATE $? "Downloaded docker-compose"

chmod +x /usr/local/bin/docker-compose
VALIDATE $? "Moved docker-compose to local bin"

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/
VALIDATE $? "kubectl Installation"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

VALIDATE $? "AWS CLI v2 Installation"

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
VALIDATE $? "Downloaded eksctl command"
chmod +x /tmp/eksctl
VALIDATE $?  "Added execute permissions to eksctl"
mv /tmp/eksctl /usr/local/bin
VALIDATE $? "moved eksctl to bin folder"

VALIDATE $? "AWS CLI v2 Installation"

git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

VALIDATE $? "kubens Installation"

echo  -e "$R You need logout and login to the server $N"