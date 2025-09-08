#!/bin/bash

REGION="ap-northeast-1"

echo "| ResourceARN | TagKey | TagValue |"
echo "|-------------|--------|----------|"

aws resourcegroupstaggingapi get-resources --region $REGION --output json \
  | jq -r '
    .ResourceTagMappingList[]
    | .ResourceARN as $arn
    | if (.Tags | length) > 0 then
        .Tags[] | "| " + $arn + " | " + .Key + " | " + .Value + " |"
      else
        "| " + $arn + " | - | - |"
      end
  '

