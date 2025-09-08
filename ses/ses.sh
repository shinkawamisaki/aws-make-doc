#!/bin/bash

REGION="ap-northeast-1"

echo "| Identity名 | 種別 | 検証状態 | DKIM有効 | 備考 |"
echo "|-------------|--------|------------|------------|------|"

IDENTITIES=$(aws ses list-identities --region "$REGION" --query 'Identities[*]' --output text)

for IDENTITY in $IDENTITIES; do
  TYPE="その他"
  [[ "$IDENTITY" == *@* ]] && TYPE="EmailAddress" || TYPE="Domain"

  VERIFY_STATUS=$(aws ses get-identity-verification-attributes \
    --identities "$IDENTITY" \
    --region "$REGION" \
    --query "VerificationAttributes.\"$IDENTITY\".VerificationStatus" \
    --output text)

  [[ "$VERIFY_STATUS" == "Success" ]] && VERIFIED="OK" || VERIFIED="NG"

  DKIM_ENABLED=$(aws ses get-identity-dkim-attributes \
    --identities "$IDENTITY" \
    --region "$REGION" \
    --query "DkimAttributes.\"$IDENTITY\".DkimEnabled" \
    --output text)

  [[ "$DKIM_ENABLED" == "True" ]] && DKIM="OK" || DKIM="NG"

  echo "| $IDENTITY | $TYPE | $VERIFIED | $DKIM | |"

done
