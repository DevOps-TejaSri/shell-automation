#!/bin/bash

SG_ID="sg-01e4ec5fcb9ead862"
AMI_ID="ami-0220d79f3f480ecf5"
for instance in $@
do 
   aws ec2 run-instance --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{key=Name,Value=$instance}]" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text
done