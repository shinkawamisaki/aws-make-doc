#!/bin/bash

echo "| ユーザー名 | MFAデバイス登録数 | MFA有効？ | デバイスARN | 備考 |"
echo "|------------|--------------------|------------|--------------|------|"

USERNAMES=$(aws iam list-users --query 'Users[*].UserName' --output text)

for USERNAME in $USERNAMES; do
  MFA_DEVICES_JSON=$(aws iam list-mfa-devices --user-name "$USERNAME" --output json)
  MFA_COUNT=$(echo "$MFA_DEVICES_JSON" | jq '.MFADevices | length')

  if [[ "$MFA_COUNT" -gt 0 ]]; then
    DEVICE_ARN=$(echo "$MFA_DEVICES_JSON" | jq -r '.MFADevices[0].SerialNumber')
    MFA_ENABLED="OK"
  else
    DEVICE_ARN="-"
    MFA_ENABLED="NG"
  fi

  echo "| $USERNAME | $MFA_COUNT | $MFA_ENABLED | $DEVICE_ARN | |"
done

