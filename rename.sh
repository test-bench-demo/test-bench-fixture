#!/usr/bin/env bash

set -euo pipefail

function rename-directories {
  local replacement=$1

  for dir in $(find . -type d -name "*template*"); do
    local dest="${dir//template/$replacement}"

    mkdir -vp "$(dirname "$dest")"
    mv -v "$dir" "$dest"
  done
}

function rename-files {
  local replacement=$1

  for file in $(find . -type f -name "*template*"); do
    local dest="${file//template/$replacement}"

    mkdir -vp "$(dirname "$dest")"
    mv -v "$file" "$dest"
  done
}

function replace-tokens {
  local token=$1
  local replacement=$2

  echo "Replacing $token with $replacement"

  files=$(grep --exclude rename.sh -rl "$token" .)

  if grep -q "GNU sed" <<<$(sed --version 2>/dev/null); then
    xargs sed -i "s/$token/${replacement//\//\\/}/g" <<<"$files"
  else
    xargs sed -i '' "s/$token/${replacement//\//\\/}/g" <<<"$files"
  fi
}

function title-case {
  set ${*,,}
  echo ${*^}
}

if [ "$#" -ne 2 ]; then
  echo "Usage: rename.sh <gem-name> <license: 'MIT' or 'none'>"
  echo "e.g. rename.sh some_namespace-other_namespace MIT"
  exit 1
fi

gem_name=$1
repo_name=${gem_name//_/-}
project_name=$(title-case "${repo_name//-/ }")
path=${gem_name//-/\/}

github_org=${GIT_AUTHORITY_PATH#git@github.com:}

case "${2,,}" in
  "mit")
    license="MIT"
    homepage="http://example.com"
    ;;
  "none")
    license="None"
    homepage="https://github.com/$github_org/$repo_name"
    ;;
  *)
    echo "Unsupported license $3"
    exit 1
    ;;
esac

echo
echo "Renaming Project"
echo "= = ="
echo
echo "Gem Name: $gem_name"
echo "Repository Name: $repo_name"
echo "Project Name: $project_name"
echo "Lib Path: lib/$path"
echo "Homepage: $homepage"
echo "License: $license"
echo "GitHub Organization: $github_org"

if [ "${PROMPT:-on}" = "on" ]; then
  echo
  echo "If everything is correct, press return (Ctrl+c to abort)"
  read -r
fi

echo
echo "Writing $gem_name.gemspec"
echo "- - -"
mv -v template.gemspec "$gem_name.gemspec"

echo
echo "Renaming directories"
echo "- - -"
rename-directories "$path"

echo
echo "Renaming files"
echo "- - -"
rename-files "$path"

echo
echo "Replacing tokens"
echo "- - -"
replace-tokens "TEMPLATE-GEM-NAME" "$gem_name"
replace-tokens "TEMPLATE-REPO-NAME" "$repo_name"
replace-tokens "TEMPLATE-PROJECT-NAME" "$project_name"
replace-tokens "TEMPLATE-HOMEPAGE" "$homepage"
replace-tokens "TEMPLATE-LICENSE" "$license"
replace-tokens "TEMPLATE-GITHUB-ORG" "$github_org"

echo
echo "Writing README"
echo "- - -"
mv -v TEMPLATE-README.md README.md

echo
echo "Configuring license ($license)"
echo "- - "

for license_file in *-License.txt; do
  if [ "${license_file#$license}" = "-License.txt" ]; then
    echo "Preserving $license_file"
  else
    rm -v $license_file
  fi
done

if [ "$license" = "None" ]; then
  ruby -p -i -e "\$_.clear if \$_.match?(/license = ['\"]None['\"]/)" $gem_name.gemspec
  echo "Removed license from $gem_name.gemspec"
else
  ruby -p -i -e "\$_.clear if \$_.match?(/['\"]allowed_push_host['\"]/)" $gem_name.gemspec
  echo "Removed allowed_push_host from $gem_name.gemspec"
fi

echo
echo "Deleting rename.sh"
echo "- - -"
rm -v rename.sh

echo
echo "- - -"
echo "(done)"
