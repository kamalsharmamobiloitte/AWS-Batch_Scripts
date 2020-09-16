#!/bin/bash

# 1 Create Backup on behalf of the tags
EC2_BACKUP=`aws ec2 describe-instances --filters "Name=tag:backup1,Values=true" | jq -r '.Reservations[] | .Instances[] | .InstanceId '`
TIME_CURRENT=`date +%Y%m%d%H%M%S`
echo "${EC2_BACKUP}"

for AMI_ID in ${EC2_BACKUP}; do

    INSTANCE_NAME=`aws ec2 describe-tags --filters "Name=resource-type,Values=instance" "Name=resource-id,Values=${AMI_ID}" "Name=key,Values=Name" | jq -r '.Tags[] | .Value '`

    TEMP_NUMBER_OF_BACKUPS=`aws ec2 describe-tags --filters "Name=resource-id,Values=${AMI_ID}"  --query "Tags[?Key=='number-of-backups'].Value | [0]"`

    NUMBER_OF_BACKUPS=${TEMP_NUMBER_OF_BACKUPS//[!0-9]/}
   
    AMI_Image_Prefix="${AMI_ID}_backup"
   
    NUMBER_OF_AMI=`aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=tag:SearchKeyword,Values=${AMI_Image_Prefix}"  --query "length(Tags[*])"`
   
    echo "NoOfBackup - ${NUMBER_OF_BACKUPS} and NumberOFAmi -  ${NUMBER_OF_AMI}"
   
    if [ -z "$NUMBER_OF_BACKUPS" ]
    
    then
       
       
        if [ $NUMBER_OF_AMI -eq 3 ]
        then  
            OLDER_AMI=`aws ec2 describe-images --filter "Name=tag:SearchKeyword,Values=${AMI_Image_Prefix}*"  --query "sort_by(Images,&CreationDate)[:1]" | jq -r '.[] | .ImageId'`        
            echo "Deregistering image ${OLDER_AMI}"
            DEREGIS=`aws ec2 deregister-image --image-id ${OLDER_AMI}`     
        fi
       
        NEW_AMI_ID=`aws ec2 create-image --instance-id ${AMI_ID} --name "${INSTANCE_NAME}_${TIME_CURRENT}" --no-reboot | jq -r '.ImageId' `
        echo "AMI ${NEW_AMI_ID} created for instance ${AMI_ID}"
        # 1-4 Create a tag for search for later use
        aws ec2 create-tags --resources ${NEW_AMI_ID} --tags Key=SearchKeyword,Value=${AMI_Image_Prefix}
       
    else
        
        

        if [ $NUMBER_OF_AMI -ge $NUMBER_OF_BACKUPS ]
        then  
            OLDER_AMI=`aws ec2 describe-images --filter "Name=tag:SearchKeyword,Values=${AMI_Image_Prefix}*"  --query "sort_by(Images,&CreationDate)[:1]" | jq -r '.[] | .ImageId'`        
            echo "Deregistering image ${OLDER_AMI}"
            DEREGIS=`aws ec2 deregister-image --image-id ${OLDER_AMI}`
        fi
       
        NEW_AMI_ID=`aws ec2 create-image --instance-id ${AMI_ID} --name "${INSTANCE_NAME}_${TIME_CURRENT}" --no-reboot | jq -r '.ImageId' `
        echo "AMI ${NEW_AMI_ID} created for instance ${AMI_ID}"
        # 1-4 Create a tag for search for later use
        aws ec2 create-tags --resources ${NEW_AMI_ID} --tags Key=SearchKeyword,Value=${AMI_Image_Prefix}

    fi

done