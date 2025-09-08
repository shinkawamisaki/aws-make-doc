#!/bin/bash

REGION="ap-northeast-1"

echo "| 種別 | 名前 | DNS名 | スキーム | IPタイプ | セキュリティグループ | VPC | 備考 |"
echo "|------|------|--------|---------|----------|------------------|-----|------|"

aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[*]' --output json | jq -c '.[]' | while read -r elb; do
  TYPE=$(echo "$elb" | jq -r '.Type') # application / network / gateway
  NAME=$(echo "$elb" | jq -r '.LoadBalancerName')
  DNS=$(echo "$elb" | jq -r '.DNSName')
  SCHEME=$(echo "$elb" | jq -r '.Scheme') # internet-facing / internal
  IP_TYPE=$(echo "$elb" | jq -r '.IpAddressType')
  VPC=$(echo "$elb" | jq -r '.VpcId')
  ARN=$(echo "$elb" | jq -r '.LoadBalancerArn')

  if [[ "$TYPE" == "application" || "$TYPE" == "gateway" ]]; then
    SG=$(echo "$elb" | jq -r '.SecurityGroups | join(",")')
  else
    SG="N/A"
  fi

  echo "| $TYPE | $NAME | $DNS | $SCHEME | $IP_TYPE | $SG | $VPC | |"
done

aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[*]' --output json | jq -c '.[]' | while read -r classic; do
  NAME=$(echo "$classic" | jq -r '.LoadBalancerName')
  DNS=$(echo "$classic" | jq -r '.DNSName')
  SCHEME=$(echo "$classic" | jq -r '.Scheme') # internet-facing / internal
  SG=$(echo "$classic" | jq -r '.SecurityGroups | join(",")')
  VPC=$(echo "$classic" | jq -r '.VPCId')

  echo "| classic | $NAME | $DNS | $SCHEME | IPv4 | $SG | $VPC | |"
done

