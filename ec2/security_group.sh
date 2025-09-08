#!/bin/bash

REGION="ap-northeast-1"

echo "| SG ID | 名前 | 説明 | VPC | 種別 | プロトコル | ポート範囲 | ソース/送信先 | 備考 |"
echo "|-------|------|------|-----|------|------------|-------------|----------------|------|"

aws ec2 describe-security-groups --region "$REGION" --query 'SecurityGroups[*]' --output json |
jq -c '.[]' | while read -r group; do
  SG_ID=$(echo "$group" | jq -r '.GroupId')
  NAME=$(echo "$group" | jq -r '.GroupName')
  DESC=$(echo "$group" | jq -r '.Description')
  VPC_ID=$(echo "$group" | jq -r '.VpcId')

  PERMS_TYPE=$(echo "$group" | jq -r '.IpPermissions | type')
  if [[ "$PERMS_TYPE" == "array" ]]; then
    echo "$group" | jq -c '.IpPermissions[]?' | while read -r rule; do
      PROTOCOL=$(echo "$rule" | jq -r '.IpProtocol')
      FROM_PORT=$(echo "$rule" | jq -r '.FromPort // "ALL"')
      TO_PORT=$(echo "$rule" | jq -r '.ToPort // "ALL"')
      [[ "$FROM_PORT" == "ALL" && "$TO_PORT" == "ALL" ]] && PORT_RANGE="ALL" || PORT_RANGE="${FROM_PORT}-${TO_PORT}"

      SOURCES=$(echo "$rule" | jq -r '.IpRanges[]?.CidrIp, .Ipv6Ranges[]?.CidrIpv6, .UserIdGroupPairs[]?.GroupId' | paste -sd "," -)
      [[ -z "$SOURCES" ]] && SOURCES="-"

      echo "| $SG_ID | $NAME | $DESC | $VPC_ID | インバウンド | $PROTOCOL | $PORT_RANGE | $SOURCES | |"
    done
  fi

  EGRESS_TYPE=$(echo "$group" | jq -r '.IpPermissionsEgress | type')
  if [[ "$EGRESS_TYPE" == "array" ]]; then
    echo "$group" | jq -c '.IpPermissionsEgress[]?' | while read -r rule; do
      PROTOCOL=$(echo "$rule" | jq -r '.IpProtocol')
      FROM_PORT=$(echo "$rule" | jq -r '.FromPort // "ALL"')
      TO_PORT=$(echo "$rule" | jq -r '.ToPort // "ALL"')
      [[ "$FROM_PORT" == "ALL" && "$TO_PORT" == "ALL" ]] && PORT_RANGE="ALL" || PORT_RANGE="${FROM_PORT}-${TO_PORT}"

      DESTS=$(echo "$rule" | jq -r '.IpRanges[]?.CidrIp, .Ipv6Ranges[]?.CidrIpv6, .UserIdGroupPairs[]?.GroupId' | paste -sd "," -)
      [[ -z "$DESTS" ]] && DESTS="-"

      echo "| $SG_ID | $NAME | $DESC | $VPC_ID | アウトバウンド | $PROTOCOL | $PORT_RANGE | $DESTS | |"
    done
  fi
done

