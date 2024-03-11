#!/bin/bash

# Define your resource IDs here
# Remove resource create by MultInstanceCreate.sh

#INSTANCE_IDS=("instance-id-1" "instance-id-2" "instance-id-3") # Replace with your actual instance IDs
#SG_ID="your-security-group-id" # Replace with your actual security group ID
#IGW_ID="your-internet-gateway-id" # Replace with your actual internet gateway ID
#SUBNET_ID="your-subnet-id" # Replace with your actual subnet ID
#VPC_ID="your-vpc-id" # Replace with your actual VPC ID

# Terminate EC2 instances
echo "Terminating EC2 instances..."
aws ec2 terminate-instances --instance-ids "${INSTANCE_IDS[@]}"
echo "Waiting for EC2 instances to terminate..."
for ID in "${INSTANCE_IDS[@]}"; do
    aws ec2 wait instance-terminated --instance-ids $ID
done
echo "EC2 instances terminated."

# Delete security group (wait a bit to allow for instance termination to fully propagate)
echo "Waiting before deleting security group..."
sleep 60
echo "Deleting security group: $SG_ID"
aws ec2 delete-security-group --group-id $SG_ID

# Detach and delete Internet Gateway
echo "Detaching Internet Gateway: $IGW_ID from VPC: $VPC_ID"
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Deleting Internet Gateway: $IGW_ID"
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# Delete subnet
echo "Deleting subnet: $SUBNET_ID"
aws ec2 delete-subnet --subnet-id $SUBNET_ID

# Delete VPC
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "All specified AWS resources have been deleted."
