# 1 Create Backup on behalf of the tags
EC2_DAILYNIGHT=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" | jq -r '.Reservations[] | .Instances[] | .InstanceId '`

TIME_CURRENT=`date +%Y%m%d%H%M%S`

for AMI_ID in ${EC2_DAILYNIGHT}; do

AZ=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].Placement.AvailabilityZone | [0]" | tr -d '"'`       

IP=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].PublicIpAddress | [0]" | tr -d '"'`

INSTANCE_TYPE=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].InstanceType | [0]" | tr -d '"'`

KEY_PAIR=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].KeyName | [0]" | tr -d '"'`

SECURITY_GROUP=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].SecurityGroups[*].GroupId | [0]"`

SUBNET_ID=`aws ec2 describe-instances --filters "Name=tag:Name,Values=AIS 1.0/2.0 FTP Testing Server" --query "Reservations[*].Instances[0].SubnetId | [0]" | tr -d '"'`

#NEW_AMI_ID=`aws ec2 create-image --instance-id ${AMI_ID} --name "${INSTANCE_NAME}_${TIME_CURRENT}_daily" --no-reboot | jq -r '.ImageId' `

echo "AMI ${NEW_AMI_ID} created for instance ${AMI_ID}  with ${AZ} and ${IP}"

# 1-4 Create a tag for search for later use
#aws ec2 create-tags --resources ${NEW_AMI_ID} --tags Key=DailyNight,Value=true Key=AssignedAZ,Value=${AZ}" Key=AssignedIP,Value=${IP} 
Key=AssignedInstanceType,Value=${INSTANCE_TYPE} Key=AssignedKeyPair,Value=${KEY_PAIR} Key=AssignedSG,Value=${SECURITY_GROUP} Key=AssignedSubnet,Value=${SUBNET_ID}

#aws terminate-instances --instance-ids ${AMI_ID}

done



------------------------------------------------------------------------------------------------------------------------------------------------------------------


# 1 Crete Instance from Night Backup
AMI_DAILYNIGHT=`aws ec2 describe-images --filters "Name=tag:DailyNight,Values=true" | jq -r '.Images[] | .ImageId'`

TIME_CURRENT=`date +%Y%m%d%H%M%S`

for AMI_ID in ${AMI_DAILYNIGHT}; do

AZ=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedAZ'].Value | [0]" | tr -d '"'`       

IP=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedIP'].Value | [0]" | tr -d '"'`

INSTANCE_TYPE=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedInstanceType'].Value | [0]" | tr -d '"'`

KEY_PAIR=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedKeyPair'].Value | [0]" | tr -d '"'`

SECURITY_GROUP=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedSG'].Value | [0]"`

SUBNET_ID=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=${AMI_ID}" --query "Tags[?Key=='AssignedSubnet'].Value | [0]" | tr -d '"'`

#NEW_EC2_ID=`aws ec2 run-instances --image-id ${AMI_ID} --associate-public-ip-address ${IP} --instance-type ${INSTANCE_TYPE} --key-name ${KEY_PAIR} --security-group-ids ${SECURITY_GROUP}  --subnet-id ${SUBNET_ID}`

echo "Instance ${NEW_EC2_ID} created from ${AMI_ID} with ${AZ} and ${IP}"

done






