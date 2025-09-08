#!/bin/bash

REGION="ap-northeast-1"

echo "| VPC ID | CIDR | サブネットID | AZ | サブネットCIDR | パブリック | IGW | NATGW | 備考 |"
echo "|--------|------|--------------|----|----------------|------------|-----|-------|------|"

VPCS=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[*].VpcId' --output text)

for VPC in $VPCS; do
  VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids "$VPC" --region "$REGION" --query 'Vpcs[0].CidrBlock' --output text)

  SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC" --region "$REGION" --query 'Subnets[*]' --output json)

  echo "$SUBNETS" | jq -c '.[]' | while read -r subnet; do
    SUBNET_ID=$(echo "$subnet" | jq -r '.SubnetId')
    AZ=$(echo "$subnet" | jq -r '.AvailabilityZone')
    CIDR=$(echo "$subnet" | jq -r '.CidrBlock')
    MAP_PUBLIC=$(echo "$subnet" | jq -r '.MapPublicIpOnLaunch')
    PUBLIC="NG"
    [[ "$MAP_PUBLIC" == "true" ]] && PUBLIC="OK"

    IGW_ATTACHED="NG"
    IGWS=$(aws ec2 describe-internet-gateways \
      --filters Name=attachment.vpc-id,Values="$VPC" \
      --region "$REGION" \
      --query 'InternetGateways[*].InternetGatewayId' --output text)
    [[ -n "$IGWS" ]] && IGW_ATTACHED="OK"

    NATGWS=$(aws ec2 describe-nat-gateways \
      --filter Name=subnet-id,Values="$SUBNET_ID" \
      --region "$REGION" \
      --query 'NatGateways[*].NatGatewayId' --output text)
    NATGW="NG"
    [[ -n "$NATGWS" ]] && NATGW="OK"

    echo "| $VPC | $VPC_CIDR | $SUBNET_ID | $AZ | $CIDR | $PUBLIC | $IGW_ATTACHED | $NATGW | |"
  done
done

