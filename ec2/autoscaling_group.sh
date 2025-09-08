#!/bin/bash

REGION="ap-northeast-1"

echo "| ASG名 | 状態 | 最小/最大/希望 | 起動設定名 | 対象インスタンス数 | VPCゾーン | 備考 |"
echo "|--------|------|----------------|--------------|-------------------|-----------|------|"

aws autoscaling describe-auto-scaling-groups --region "$REGION" --output json | jq -c '.AutoScalingGroups[]' | while read -r asg; do
  NAME=$(echo "$asg" | jq -r '.AutoScalingGroupName')
  STATUS=$(echo "$asg" | jq -r '.Status // "-"')
  MIN=$(echo "$asg" | jq -r '.MinSize')
  MAX=$(echo "$asg" | jq -r '.MaxSize')
  DESIRED=$(echo "$asg" | jq -r '.DesiredCapacity')
  LAUNCH_TEMPLATE=$(echo "$asg" | jq -r '.LaunchTemplate.LaunchTemplateName // .LaunchConfigurationName // "-"')
  INSTANCE_COUNT=$(echo "$asg" | jq '.Instances | length')
  VPC_ZONES=$(echo "$asg" | jq -r '.VPCZoneIdentifier')

  echo "| $NAME | $STATUS | $MIN / $MAX / $DESIRED | $LAUNCH_TEMPLATE | $INSTANCE_COUNT | $VPC_ZONES | |"
done

