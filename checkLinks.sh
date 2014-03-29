#!/usr/bin/env bash
echo "Preparing for check..."
brew detox >/dev/null 2>&1
[ -d "/Volumes/SHARED/Dropbox/Public/CaskTasting.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskTasting.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskPassed.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskPassed.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskFailed.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskFailed.part"
TOTAL=$( ls -1 /usr/local/Library/Taps/phinze-cask/Casks | wc -l | sed -e 's/^ *//' -e 's/ *$//')
# TOTAL=$(echo $TOTALSTRING | sed -E 's/^.{4}//')
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
counter=0
passed=0
failed=0
echo "Check started at $(date)" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
echo "Check started at $(date)"
for f in $FILES
do
  ((counter++))
  echo -e "\033[1;33mTesting $counter/$TOTAL\033[22;0m"
  brew cask audit --download $f
  if [ "$?" = 0 ]
    then
    ((passed++))
    echo "${2%.*}: passed" >> /Volumes/SHARED/Dropbox/Public/CaskPassed.part
  else
    ((failed++))
    echo "${2%.*}: passed" >> /Volumes/SHARED/Dropbox/Public/CaskFailed.part
  fi
done
echo "Check finished at $(date)" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
echo "Check finished at $(date) ($passed \033[1;32mpassed\033[22;0m, $failed \033[1;31mfailed\033[22;0m)"
mv /Volumes/SHARED/Dropbox/Public/CaskTasting.txt /Volumes/SHARED/Dropbox/Public/CaskHistory/CaskTasting-$(date +%F-%T).txt
mv /Volumes/SHARED/Dropbox/Public/CaskPassed.txt /Volumes/SHARED/Dropbox/Public/CaskHistory/CaskPassed-$(date +%F-%T).txt
mv /Volumes/SHARED/Dropbox/Public/CaskFailed.txt /Volumes/SHARED/Dropbox/Public/CaskHistory/CaskFailed-$(date +%F-%T).txt

mv /Volumes/SHARED/Dropbox/Public/CaskTasting.part /Volumes/SHARED/Dropbox/Public/CaskTasting.txt
mv /Volumes/SHARED/Dropbox/Public/CaskPassed.part /Volumes/SHARED/Dropbox/Public/CaskPassed.txt
mv /Volumes/SHARED/Dropbox/Public/CaskFailed.part /Volumes/SHARED/Dropbox/Public/CaskFailed.txt

rm /Volumes/SHARED/Dropbox/Public/CaskTasting.part
rm /Volumes/SHARED/Dropbox/Public/CaskPassed.part
rm /Volumes/SHARED/Dropbox/Public/CaskFailed.part
