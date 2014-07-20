#!/usr/bin/env bash

echo "Preparing for check..."
cd /Volumes/MacData/homebrew/cask-tasting
git checkout master
brew detox >/dev/null 2>&1
[ -e "CaskTasting.part" ] && rm "CaskTasting.part"
[ -e "CaskPassed.part" ] && rm "CaskPassed.part"
[ -e "CaskDLError.part" ] && rm "CaskDLError.part"
[ -e "CaskSumError.part" ] && rm "CaskSumError.part"
[ -e "CaskNoSum.part" ] && rm "CaskNoSum.part"

TOTAL=$( ls -1 /usr/local/Library/Taps/caskroom/homebrew-cask/Casks | wc -l | sed -e 's/^ *//' -e 's/ *$//')
# TOTAL=$(echo $TOTALSTRING | sed -E 's/^.{4}//')
FILES=/usr/local/Library/Taps/caskroom/homebrew-cask/Casks/*.rb
counter=0
echo "Check started at $(date)" >> CaskTasting.part
echo "Check started at $(date)"
for f in $FILES
do
  ((counter++))
  [ -e "Testfile" ] && rm Testfile
  if [[ $(brew cask _stanza sha256 $f) == ":no_check" ]]
    then
    SHA_ALG=NONE
    EXPECTED_SHA=""
  else
    SHA_ALG=256
    EXPECTED_SHA="$(brew cask _stanza sha256 $f)"
  fi
  if [ "$SHA_ALG" != "NONE" ]
    then
    echo -e "Downloading $(basename ${f%.*})"
    brew cask fetch "${f}"
    find "$(brew --cache)" -type f -exec mv "{}" "./Testfile" \;
    # ACTUAL_SHA=$(echo $(curl -Ls "$URL" | shasum -a $SHA_ALG) | cut -d \  -f 1)
    ACTUAL_SHA=$(shasum -a 256 Testfile | cut -d \  -f 1)
    if [ "$EXPECTED_SHA" = "$ACTUAL_SHA" ]
      then
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;32mpassed\033[22;0m"
      echo -e "$(basename ${f%.*}): passed" >> CaskTasting.part
      echo "$(basename ${f%.*})" >> CaskPassed.part
    elif [ "$ACTUAL_SHA" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]
      then
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;31mdownload error\033[22;0m"
      echo -e "$(basename ${f%.*}): download error" >> CaskTasting.part
      echo "$(basename ${f%.*})" >> CaskDLFailed.part
    else
      echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;31mSHA-$SHA_ALG mismatch!\033[22;0m"
      echo -e "$(basename ${f%.*}): SHA-$SHA_ALG mismatch!" >> CaskTasting.part
      echo -e "  Expected: $EXPECTED_SHA" >> CaskTasting.part
      echo -e "  Actual  : $ACTUAL_SHA" >> CaskTasting.part
      echo "$(basename ${f%.*})" >> CaskSumError.part
    fi
    # echo $SHA_ALG
    # echo $URL
    # echo $EXPECTED_SHA
    # echo $ACTUAL_SHA
  elif [ "$SHA_ALG" = "NONE" ]
    then
    echo -e "$(basename ${f%.*}) ($counter/$TOTAL): \033[1;34mno checksum\033[22;0m"
    echo -e "$(basename ${f%.*}): no checksum" >> CaskTasting.part
    echo "$(basename ${f%.*})" >> CaskNoSum.part
  fi
  [ -e "Testfile" ] && rm Testfile
  rm -rf "$(brew --cache)"
done
echo "Check finished at $(date)" >> ./CaskTasting.part
echo "Check finished at $(date)"

mv CaskTasting.part CaskTasting.txt
mv CaskPassed.part CaskPassed.txt
mv CaskDLFailed.part CaskDLFailed.txt
mv CaskSumError.part CaskSumError.txt
mv CaskNoSum.part CaskNoSum.txt

echo "Sending data to master..."
[ -e "Testfile" ] && rm Testfile
git add . 2>/dev/null
git commit -m "Cask taster reporting for duty: $(date)" 2>/dev/null
git push 2>/dev/null
