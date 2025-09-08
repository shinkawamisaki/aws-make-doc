#!/bin/bash

echo "| ユーザー名 | 所属グループ | グループのマネージドポリシー | グループのインラインポリシー | ユーザー直付けポリシー |"
echo "|------------|--------------|------------------------------|------------------------------|------------------------|"

aws iam get-account-authorization-details --filter User Group --output json | jq -r '
  def join_or(arr; empty): if (arr|length)>0 then arr|join(",") else empty end;

  . as $root
  | ($root.GroupDetailList // []) as $groups
  | reduce $groups[] as $g ({}; .[$g.GroupName] = {
      managed: ($g.AttachedManagedPolicies // [] | map(.PolicyName)),
      inline:  ($g.GroupPolicyList        // [] | map(.PolicyName))
    }) 
  | . as $gmap
  | $root.UserDetailList[]
  | . as $u
  | ($u.GroupList // []) as $ugs
  | ($ugs | map(($gmap[.]//{}).managed) | add // []) as $grp_managed
  | ($ugs | map(($gmap[.]//{}).inline ) | add // []) as $grp_inline
  | "| \($u.UserName) | \(join_or($ugs; "-")) | \(join_or($grp_managed|unique; "-")) | \(join_or($grp_inline|unique; "-")) | \(join_or(($u.AttachedManagedPolicies // [] | map(.PolicyName)); "NG")) |"
'

