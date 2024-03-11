#!/bin/bash
# Remove all resource create by UbuntuInstanceCreate.sh

# Define the resource IDs
#INSTANCE_ID="your-instance-id" # Replace with your actual instance ID
#KEY_NAME="MyKeyPair"
#SG_ID="your-security-group-id" # Replace with your actual security group ID
#IGW_ID="your-internet-gateway-id" # Replace with your actual internet gateway ID
#SUBNET_ID="your-subnet-id" # Replace with your actual subnet ID
#VPC_ID="your-vpc-id" # Replace with your actual VPC ID

# Terminate the EC2 instance
echo "Terminating EC2 instance: $INSTANCE_ID"
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
echo "Waiting for EC2 instance to terminate..."
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "EC2 instance terminated."

# Delete the key pair
echo "Deleting key pair: $KEY_NAME"
aws ec2 delete-key-pair --key-name $KEY_NAME

# Delete the security group (ensure no dependencies)
echo "Deleting security group: $SG_ID"
aws ec2 delete-security-group --group-id $SG_ID

# Detach and delete the internet gateway
echo "Detaching Internet Gateway: $IGW_ID from VPC: $VPC_ID"
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Deleting Internet Gateway: $IGW_ID"
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

# Delete the subnet
echo "Deleting subnet: $SUBNET_ID"
aws ec2 delete-subnet --subnet-id $SUBNET_ID

# Delete the VPC
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "All resources have been deleted."
