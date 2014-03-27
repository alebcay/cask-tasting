#!/usr/bin/env bash
echo "Preparing for check..."
brew detox >/dev/null 2>&1
[ -d "/Volumes/SHARED/Dropbox/Public/CaskTasting.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskTasting.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskPassed.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskPassed.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskDLError.part" ] && rm "//Volumes/SHARED/Dropbox/Public/CaskDLError.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskSumError.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskSumError.part"
[ -d "/Volumes/SHARED/Dropbox/Public/CaskNoSum.part" ] && rm "/Volumes/SHARED/Dropbox/Public/CaskNoSum.part"
TOTAL=$( ls -1 /usr/local/Library/Taps/phinze-cask/Casks | wc -l | sed -e 's/^ *//' -e 's/ *$//')
# TOTAL=$(echo $TOTALSTRING | sed -E 's/^.{4}//')
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
counter=0
passed=0
dlfailed=0
sumfailed=0
nosum=0
echo "Check started at $(date)" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
echo "Check started at $(date)"
for f in $FILES
do
  ((counter++))
  [ -f "Testfile" ] && rm Testfile
  while read line
  do
    if [[ $line == *url* ]]
      then
      URL=$(echo $line | tr -d "'" | cut -d \  -f 2)
    fi
    if [[ $line == *sha256* ]]
      then
      SHA_ALG=256
      EXPECTED_SHA=$(echo $line | cut -d \  -f 2 | sed -e "s/^'//"  -e "s/'$//")
    fi
    if [[ $line == *no_checksum* ]]
      then
      SHA_ALG=NONE
      EXPECTED_SHA=""
    fi
  done < $f
  if [ "$SHA_ALG" != "NONE" ]
    then
    echo -e "Downloading $(basename ${f%.*})"
    # axel -a -o Testfile "$URL"
    curl -L# "$URL" > Testfile
    # ACTUAL_SHA=$(echo $(curl -Ls "$URL" | shasum -a $SHA_ALG) | cut -d \  -f 1)
    ACTUAL_SHA=$(shasum -a 256 Testfile | cut -d \  -f 1)
    if [ "$EXPECTED_SHA" = "$ACTUAL_SHA" ]
      then
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;32mpassed\033[22;0m"
      ((passed++))
      echo -e "$(basename ${f%.*}): passed" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
      echo "$(basename ${f%.*})" >> /Volumes/SHARED/Dropbox/Public/CaskPassed.part
    elif [ "$ACTUAL_SHA" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]
      then
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;31mdownload error\033[22;0m"
      ((dlfailed++))
      echo -e "$(basename ${f%.*}): download error" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
      echo "$(basename ${f%.*})" >> /Volumes/SHARED/Dropbox/Public/CaskDLFailed.part
    else
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;31mSHA-$SHA_ALG mismatch!\033[22;0m"
      ((sumfailed++))
      echo -e "$(basename ${f%.*}): SHA-$SHA_ALG mismatch!" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
      echo -e "  Expected: $EXPECTED_SHA" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
      echo -e "  Actual  : $ACTUAL_SHA" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
      echo "$(basename ${f%.*})" >> /Volumes/SHARED/Dropbox/Public/CaskSumError.part
    fi
    # echo $SHA_ALG
    # echo $URL
    # echo $EXPECTED_SHA
    # echo $ACTUAL_SHA
  elif [ "$SHA_ALG" = "NONE" ]
    then
    echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;34mno checksum\033[22;0m"
    ((nosum++))
    echo -e "$(basename ${f%.*}): no checksum" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
    echo "$(basename ${f%.*})" >> /Volumes/SHARED/Dropbox/Public/CaskNoSum.part
  fi
done
echo "Check finished at $(date)" >> /Volumes/SHARED/Dropbox/Public/CaskTasting.part
echo "Check finished at $(date) ($passed passed, $dlfailed failed to download, $sumfailed had checksum mismatch, $nosum had no defined expected checksum)"
rm Testfile
mv /Volumes/SHARED/Dropbox/Public/CaskTasting.part /Volumes/SHARED/Dropbox/Public/CaskTasting.txt
mv /Volumes/SHARED/Dropbox/Public/CaskPassed.part /Volumes/SHARED/Dropbox/Public/CaskPassed.txt
mv /Volumes/SHARED/Dropbox/Public/CaskDLFailed.part /Volumes/SHARED/Dropbox/Public/CaskDLFailed.txt
mv /Volumes/SHARED/Dropbox/Public/CaskSumError.part /Volumes/SHARED/Dropbox/Public/CaskSumError.txt
mv /Volumes/SHARED/Dropbox/Public/CaskNoSum.part /Volumes/SHARED/Dropbox/Public/CaskNoSum.txt
