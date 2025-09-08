#!/bin/bash

echo "| 種別 | 名前 | 作成日 | 最終使用日 | MFA | アタッチポリシー |"
echo "|------|------|--------|--------------|-----|------------------|"

USERNAMES=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USERNAME in $USERNAMES; do
  CREATED=$(aws iam get-user --user-name "$USERNAME" | jq -r '.User.CreateDate')
  LAST_USED=$(aws iam get-user --user-name "$USERNAME" | jq -r '.User.PasswordLastUsed // "N/A"')
  
  MFA_COUNT=$(aws iam list-mfa-devices --user-name "$USERNAME" --query 'MFADevices' --output json | jq length)
  MFA="NG"
  [ "$MFA_COUNT" -gt 0 ] && MFA="OK"

  POLICIES=$(aws iam list-attached-user-policies --user-name "$USERNAME" \
    --query 'AttachedPolicies[*].PolicyName' --output text | paste -sd "," -)

  echo "| ユーザー | $USERNAME | $CREATED | $LAST_USED | $MFA | $POLICIES |"
done

ROLES=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)

for ROLENAME in $ROLES; do
  CREATED=$(aws iam get-role --role-name "$ROLENAME" | jq -r '.Role.CreateDate')

  POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLENAME" \
    --query 'AttachedPolicies[*].PolicyName' --output text | paste -sd "," -)

  echo "| ロール | $ROLENAME | $CREATED | - | - | $POLICIES |"
done
