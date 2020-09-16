EBS_VOLUME=`aws ec2 describe-instances --instance-ids i-0144bce2aaf7dd0f2 | jq -r '.Reservations[] | .Instances[] | .BlockDeviceMappings[] | select(.Ebs.DeleteOnTermination == false) | .Ebs.VolumeId'`

for VolumeId in ${TAGS}; do

aws ec2 delete-volume --volume-id ${VolumeId}

done


ARRAYL=`aws ec2 describe-instances --instance-ids i-0144bce2aaf7dd0f2 | jq -r '.Reservations[] | .Instances[] | .Tags[] | to_entries | map("\(.key)=\(.value|tostring)")|.[] '`
for row in  "${!ARRAYL[@]}"; #${ARRAYL}
do  
   
      echo  "${ARRAYL[row]},${ARRAYL[row-1]}"    #"${KEY_NAME}${row}"
  
done




AUTOSCALING_GROUPS=("AG1" "AG2")

for AUTOSCALING_GROUP in ${!AUTOSCALING_GROUPS[*]} 
do

  INSTANCES=`aws autoscaling describe-auto-scaling-groups --max-items 100 --auto-scaling-group-name ${AUTOSCALING_GROUP} --query "AutoScalingGroups[*].length(Instances[*]) | [0]"`
  
  if [ "$INSTANCES" -gt 0  ]; then

      DESIRED_CAPACITY=`aws autoscaling describe-auto-scaling-groups --max-items 100 --auto-scaling-group-name ${AUTOSCALING_GROUP} | jq -r '.AutoScalingGroups[] | .DesiredCapacity'`

      if [ "$DESIRED_CAPACITY" -lt 8 ]; then

          aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-auto-scaling-group --min-size 8 --desired-capacity 8

      fi
  fi

done






