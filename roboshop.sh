#!/bin/bash

SG_ID="sg-01e4ec5fcb9ead862"
AMI_ID="ami-0220d79f3f480ecf5"
for instance in $@
do 
   instance_id= $( aws ec2 run-instances \
   --image-id $AMI_ID \
   --instance-type "t3.micro" \
   --security-group-ids $SG_ID \
   --tag-specifications "ResourceType=instance,Tags=[{key=Name,Value=$instance}]" \
   --query 'Instances[0].InstanceId' \ 
   --output text )

   if [ $instance == "frontend" ]; then 
      IP=$(
          aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text
      )
   else
      IP=$(
          aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text 
      )
   fi

   echo "IP Address : $IP"
done