#!/usr/bin/env bash
cd /Volumes/MacData/homebrew/cask-tasting
echo "Preparing for check..."
brew detox >/dev/null 2>&1
[ -d "CaskTasting.part" ] && rm "CaskTasting.part"
[ -d "CaskPassed.part" ] && rm "CaskPassed.part"
[ -d "CaskFailed.part" ] && rm "CaskFailed.part"
TOTAL=$( ls -1 /usr/local/Library/Taps/phinze-cask/Casks | wc -l | sed -e 's/^ *//' -e 's/ *$//')
# TOTAL=$(echo $TOTALSTRING | sed -E 's/^.{4}//')
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
counter=0
passed=0
failed=0
echo "Check started at $(date)" >> CaskTasting.part
echo "Check started at $(date)"
for f in $FILES
do
  ((counter++))
  echo -e "\033[1;33mTesting $counter/$TOTAL\033[22;0m"
  brew cask audit --download $f
  if [ "$?" = 0 ]
    then
    ((passed++))
    echo "${2%.*}: passed" >> CaskPassed.part
  else
    ((failed++))
    echo "${2%.*}: passed" >> CaskFailed.part
  fi
done
echo "Check finished at $(date)" >> CaskTasting.part
echo "Check finished at $(date) ($passed \033[1;32mpassed\033[22;0m, $failed \033[1;31mfailed\033[22;0m)"
mv CaskTasting.txt history/CaskTasting-$(date +%F-%T).txt
mv CaskPassed.txt history/CaskPassed-$(date +%F-%T).txt
mv CaskFailed.txt history/CaskFailed-$(date +%F-%T).txt

mv CaskTasting.part CaskTasting.txt
mv CaskPassed.part CaskPassed.txt
mv CaskFailed.part CaskFailed.txt

rm CaskTasting.part
rm CaskPassed.part
rm CaskFailed.part
