#!/bin/bash
set -euo pipefail
export AWS_PAGER=""

REGION="${1:-${AWS_REGION:-ap-northeast-1}}"; export AWS_REGION="$REGION"

echo "| 名前 | タイプ | 最終変更日 | KMS暗号化キー | タグ | 機密の可能性 | 備考 |"
echo "|------|--------|------------|----------------|------|----------------|------|"

NEXT=""
while : ; do
  if [ -n "$NEXT" ]; then
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --starting-token "$NEXT" --output json)"
  else
    PAGE="$(aws ssm describe-parameters --region "$REGION" --max-items 50 --output json)"
  fi

  echo "$PAGE" | jq -r '.Parameters[]? | [.Name,.Type, (.LastModifiedDate//""), (.KeyId//"")] | @tsv' \
  | while IFS=$'\t' read -r NAME TYPE LMOD KEYID; do
      KMS="$([ "$TYPE" = "SecureString" ] && echo "${KEYID:-alias/aws/ssm}" || echo "-")"

      TAGS="$(aws ssm list-tags-for-resource --region "$REGION" --resource-type Parameter --resource-id "$NAME" --output json \
             | jq -r '[.Tags[]? | "\(.Key)=\(.Value)"] | join(", ")')"

      SECRET_FLAG=""
      if [ "$TYPE" = "SecureString" ]; then
        SECRET_FLAG="🔒"
      elif echo "$NAME" | grep -qiE '(secret|token|password|api[_-]?key|private[_-]?key)'; then
        SECRET_FLAG="⚠️"
      fi

      echo "| $NAME | $TYPE | ${LMOD:-} | $KMS | ${TAGS:-} | $SECRET_FLAG | |"
    done

  NEXT="$(echo "$PAGE" | jq -r '.NextToken // empty')"
  [ -z "$NEXT" ] && break
done

