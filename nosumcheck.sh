#!/usr/bin/env bash
doalarm() { perl -e 'alarm shift; exec @ARGV' "$@"; }

echo -ne "\033[22;0m"
rm -rf NoSumCheckResults
[ -d NoSumCheckResults ] || mkdir NoSumCheckResults
[ -e Testfile ] && rm Testfile
while read line; do
  while read subline; do
    if [[ $subline == *url* ]]
      then
      URL=$(echo $subline | tr -d "'" | cut -d \  -f 2)
    fi
  done < /usr/local/Library/Taps/phinze/homebrew-cask/Casks/$line.rb
  echo "Downloading $line"
  if [ -e nosumcheck/$line.sum ]
  then
    while read sumline; do
      SUM=sumline
    done < nosumcheck/$line.sum
    STATUS_CODE=$(curl -sIL "$URL" | grep "^HTTP" | tail -1 | perl -pe "s/.* (\d{3}) .*/\1/")
    if [[ "$STATUS_CODE" == "200" ]]
      then
      doalarm 1800 curl -L# "$URL" > Testfile
    else
      doalarm 1800 curl -L#H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36" "$URL" > Testfile
    fi
    ACTUAL_SHA=$(shasum -a 256 Testfile | cut -d \  -f 1)
    if [ "$SUM" = "$ACTUAL_SHA" ]
    then
      echo -e "$line: \033[1;32mpassed\033[22;0m"
      echo "$line: passed" >> NoSumCheckResults/CaskNoSumCheck.txt
      echo "$line" >> NoSumCheckResults/CaskNoSumCheckPassed.txt
    elif [ "$ACTUAL_SHA" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]
    then
      echo -e "$line: \033[1;31mdownload failed\033[22;0m"
      echo "$line: download failed" >> NoSumCheckResults/CaskNoSumCheck.txt
      echo "$line" >> NoSumCheckResults/CaskNoSumDLFailed.txt
    else
      echo -e "$line: \033[1;31mSHA-256 mismatch!\033[22;0m"
      echo "$line: SHA-256 mismatch!" >> NoSumCheckResults/CaskNoSumCheck.txt
      echo "  Expected: $EXPECTED_SHA" >> NoSumCheckResults/CaskNoSumCheck.txt
      echo "  Actual  : $ACTUAL_SHA" >> NoSumCheckResults/CaskNoSumCheck.txt
      echo "$line" >> NoSumChecKResults/CaskNoSumCheckFailed.txt
      echo $ACTUAL_SHA > nosumcheck/$line.sum
    fi
  else
    [ -d nosumcheck ] || mkdir nosumcheck
    STATUS_CODE=$(curl -sIL "$URL" | grep "^HTTP" | tail -1 | perl -pe "s/.* (\d{3}) .*/\1/")
    if [[ "$STATUS_CODE" == "200" ]]
      then
      doalarm 1800 curl -L# "$URL" > Testfile
    else
      doalarm 1800 curl -L#H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36" "$URL" > Testfile
    fi
    ACTUAL_SHA=$(shasum -a 256 Testfile | cut -d \  -f 1)
    echo $ACTUAL_SHA > nosumcheck/$line.sum
    echo -e "$line: \033[1;34madded\033[22;0m"
    echo "$line" >> NoSumChecKResults/CaskNoSumCheckAdded.txt
  fi
done < CaskNoSum.txt
[ -e Testfile ] && rm Testfile