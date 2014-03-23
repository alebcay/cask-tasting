brew detox
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
for f in $FILES
do
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
    # echo -ne "$(basename ${f%.*}): \033[1;33mworking\033[22;0m"
    ACTUAL_SHA=$(echo $(curl -Ls $URL | shasum -a $SHA_ALG) | cut -d \  -f 1)
    if [ "$EXPECTED_SHA" = "$ACTUAL_SHA" ]
      then
      echo -e "\r\033[K$(basename ${f%.*}): \033[1;32mpassed\033[22;0m"
    else
      echo -e "\r\033[K$(basename ${f%.*}): \033[1;31mSHA-$SHA_ALG mismatch!\033[22;0m"
      echo -e "  Expected: $EXPECTED_SHA"
      echo -e "  Actual  : $ACTUAL_SHA"
    fi
    # echo $SHA_ALG
    # echo $URL
    # echo $EXPECTED_SHA
    # echo $ACTUAL_SHA
  elif [ "$SHA_ALG" = "NONE" ]
    then
    echo -e "\r\033[K$(basename ${f%.*}): \033[1;32mno checksum\033[22;0m"
  fi
done
