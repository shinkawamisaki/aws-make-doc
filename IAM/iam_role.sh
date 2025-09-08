#!/bin/bash

REGION="ap-northeast-1"

echo "| ロール名 | 作成日 | 信頼元Principal | 条件付き？ | インラインポリシー | アタッチポリシー | タグ | 備考 |"
echo "|----------|--------|------------------|-------------|----------------------|------------------|------|------|"

ROLE_LIST=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)

for ROLE in $ROLE_LIST; do
  ROLE_DATA=$(aws iam get-role --role-name "$ROLE")
  CREATED=$(echo "$ROLE_DATA" | jq -r '.Role.CreateDate')

  TRUST=$(echo "$ROLE_DATA" | jq -r '.Role.AssumeRolePolicyDocument.Principal // {}')
  PRINCIPALS=$(echo "$TRUST" | jq -r '.. | select(type=="string")' | paste -sd "," -)

  CONDITION_COUNT=$(echo "$ROLE_DATA" | jq -r '.Role.AssumeRolePolicyDocument.Condition // {}' | jq length)
  [[ "$CONDITION_COUNT" -gt 0 ]] && CONDITION_FLAG="⚠️" || CONDITION_FLAG=""

  INLINE=$(aws iam list-role-policies --role-name "$ROLE" --query 'PolicyNames' --output text)
  [[ -n "$INLINE" ]] && INLINE_FLAG="⚠️" || INLINE_FLAG="なし"

  ATTACHED=$(aws iam list-attached-role-policies --role-name "$ROLE" \
    --query 'AttachedPolicies[*].PolicyName' --output text | paste -sd "," -)
  [[ -z "$ATTACHED" ]] && ATTACHED="なし"

  TAGS=$(aws iam list-role-tags --role-name "$ROLE" \
    --query 'Tags[*].[Key,Value]' --output text 2>/dev/null | awk '{print $1 "=" $2}' | paste -sd "," -)
  [[ -z "$TAGS" ]] && TAGS="-"

  echo "| \"$ROLE\" | \"$CREATED\" | \"$PRINCIPALS\" | \"$CONDITION_FLAG\" | \"$INLINE_FLAG\" | \"$ATTACHED\" | \"$TAGS\" | |"
done

