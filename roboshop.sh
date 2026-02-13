# #!/bin/bash


SG_ID="sg-01e4ec5fcb9ead862"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0615773238DUFIUSL8RV"
DOMAIN_NAME="nagababu.online"

for instance in "$@"
do 
   instance_id=$( aws ec2 run-instances \
      --image-id $AMI_ID \
      --instance-type "t3.micro" \
      --security-group-ids $SG_ID \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
      --query 'Instances[0].InstanceId' \
      --output text)

   if [ $instance == "frontend" ]; then 
      IP=$(
         aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text
         )
         RECORD_NAME="$DOMAIN_NAME"
   else
      IP=$(
         aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text
         )
         RECORD_NAME="$instance.$DOMAIN_NAME"
   fi

   echo "IP Address : $IP"

   aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch '
   {
      "Comment": "Testing creating a record set"
      ,"Changes": [{
         "Action"              : "UPSERT"
         ,"ResourceRecordSet"  : {
         "Name"              : "'" $RECORD_NAME "'
         ,"Type"             : "A"
         ,"TTL"              : 1
         ,"ResourceRecords"  : [{
               "Value"         : "'" $IP "'"
         }]
         }
      }]
   }
   '
   echo "RECORD UPDATE FOR $instance"

done
