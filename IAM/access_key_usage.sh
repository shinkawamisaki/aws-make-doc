#!/bin/bash

echo "| ユーザー名 | アクセスキーID | 作成日 | 最終使用日 | ステータス | 備考 |"
echo "|------------|------------------|--------|--------------|------------|------|"

mask_key() { sed -E 's/(AKIA|ASIA)([A-Z0-9]{12})([A-Z0-9]{4})/\1********\3/g'; }
aws iam list-users --output json \
| jq -r '.Users[]?.UserName' \
| while IFS= read -r USER; do
  aws iam list-access-keys --user-name "$USER" --output json \
  | jq -r '.AccessKeyMetadata[]? | [.AccessKeyId,.CreateDate,.Status] | @tsv' \
  | while IFS=$'\t' read -r AK CD ST; do
      [ -z "$AK" ] && continue
      J="$(aws iam get-access-key-last-used --access-key-id "$AK" --output json 2>/dev/null || echo '{}')"
      LU="$(echo "$J" | jq -r '.AccessKeyLastUsed.LastUsedDate // "N/A"')"
      SV="$(echo "$J" | jq -r '.AccessKeyLastUsed.ServiceName // ""')"
      RG="$(echo "$J" | jq -r '.AccessKeyLastUsed.Region // ""')"
      NOTE=""
      [ "$LU" = "N/A" ] && NOTE="未使用"
      MASKED="$(printf "%s" "$AK" | mask_key)"
      echo "| $USER | $MASKED | $CD | $LU | $SV | $RG | $ST | $NOTE |"
    done
done
