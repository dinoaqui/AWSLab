# Define basic variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
REGION="us-east-1"
AMI_ID="ami-0cd59ecaf368e5ccf" # Ubuntu 20.04 - Substitute with the appropriate AMI ID for your region
INSTANCE_TYPE="t2.micro"
KEY_NAME="MyKeyPair"

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text)
echo "VPC created: $VPC_ID"
# Tag VPC with Env:Lab
aws ec2 create-tags --resources $VPC_ID --tags Key=Env,Value=Lab

# Create subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --query 'Subnet.SubnetId' --output text)
echo "Subnet created: $SUBNET_ID"
# Tag Subnet with Env:Lab
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Env,Value=Lab

# Enable auto-assign public IP on this subnet
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
echo "Auto-assign Public IP enabled for subnet: $SUBNET_ID"

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
echo "Internet Gateway created: $IGW_ID"
# Tag Internet Gateway with Env:Lab
aws ec2 create-tags --resources $IGW_ID --tags Key=Env,Value=Lab

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

# Create route table
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Route table created: $ROUTE_TABLE_ID"
# Tag Route Table with Env:Lab
aws ec2 create-tags --resources $ROUTE_TABLE_ID --tags Key=Env,Value=Lab

# Create route to the Internet Gateway
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# Associate route table with subnet
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID

# Create security group
SG_ID=$(aws ec2 create-security-group --group-name "my-security-group" --description "My security group" --vpc-id $VPC_ID --query 'GroupId' --output text)
echo "Security group created: $SG_ID"
# Tag Security Group with Env:Lab
aws ec2 create-tags --resources $SG_ID --tags Key=Env,Value=Lab

# Allow SSH (port 22) on security group
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Create SSH key pair
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > ${KEY_NAME}.pem
if [ $? -eq 0 ]; then
    echo "Key pair created and saved as ${KEY_NAME}.pem"
    chmod 400 ${KEY_NAME}.pem
else
    echo "Failed to create key pair. Exiting."
    exit 1
fi

# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SG_ID --subnet-id $SUBNET_ID --query 'Instances[0].InstanceId' --output text)
echo "EC2 instance launched: $INSTANCE_ID"
# Tag EC2 Instance with Env:Lab
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Env,Value=Lab
