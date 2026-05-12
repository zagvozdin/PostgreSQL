#!/bin/bash
echo "Compare directories eircm and eircm_hotfix"
diff -i -y -W128 eircm eircm_hotfix --suppress-common-lines > compare.log

## diff --ignore-case --side-by-side --width=128 eircm eircm_hotfix --suppress-common-lines > compare-wide.log
