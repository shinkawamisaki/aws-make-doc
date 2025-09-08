#!/bin/bash

REGION="ap-northeast-1"

echo "| ポリシー名 | ポリシーID | 作成日 | 最終更新日 | アタッチ先タイプ | アタッチ先数 | 備考 |"
echo "|------------|-------------|----------|----------------|-------------------|---------------|------|"

POLICIES=$(aws iam list-policies --scope Local --query 'Policies[*].Arn' --output text)

for POLICY_ARN in $POLICIES; do
  POLICY_DETAIL=$(aws iam get-policy --policy-arn "$POLICY_ARN")
  
  NAME=$(echo "$POLICY_DETAIL" | jq -r '.Policy.PolicyName')
  ID=$(echo "$POLICY_DETAIL" | jq -r '.Policy.PolicyId')
  CREATED=$(echo "$POLICY_DETAIL" | jq -r '.Policy.CreateDate')
  UPDATED=$(echo "$POLICY_DETAIL" | jq -r '.Policy.UpdateDate')

  ATTACHMENTS=$(echo "$POLICY_DETAIL" | jq -r '.Policy.AttachmentCount')
  ATTACHMENT_TYPE="-"

  if [ "$ATTACHMENTS" -gt 0 ]; then
    ENTITIES=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query '{Users:PolicyUsers[*].UserName, Roles:PolicyRoles[*].RoleName, Groups:PolicyGroups[*].GroupName}' --output json)
    USER_COUNT=$(echo "$ENTITIES" | jq '.Users | length')
    ROLE_COUNT=$(echo "$ENTITIES" | jq '.Roles | length')
    GROUP_COUNT=$(echo "$ENTITIES" | jq '.Groups | length')

    ATTACHMENT_TYPE=""
    [[ $USER_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="ユーザー "
    [[ $ROLE_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="ロール "
    [[ $GROUP_COUNT -gt 0 ]] && ATTACHMENT_TYPE+="グループ "
  fi

  echo "| $NAME | $ID | $CREATED | $UPDATED | ${ATTACHMENT_TYPE:-なし} | $ATTACHMENTS | |"
done

