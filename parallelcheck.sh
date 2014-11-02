#!/usr/bin/env bash
#FILES=/usr/local/Library/Taps/caskroom/homebrew-cask/Casks/*.rb
f=$1
echo -n "$(basename ${f%.*}): "
if [[ $(brew cask _stanza sha256 $f) == ":no_check" ]]
  then
  SHA_ALG=NONE
  EXPECTED_SHA=""
else
  SHA_ALG=256
  EXPECTED_SHA="$(brew cask _stanza sha256 $f)"
fi
if [[ "$SHA_ALG" != "NONE" ]]
  then
  brew cask audit --download $f >/dev/null 2>&1
  RETURNCODE=$?
  if [[ $RETURNCODE == 0 ]]
    then
    echo -e "\033[1;32mpassed\033[22;0m"
    echo -e "$(basename ${f%.*}): passed" >> CaskTasting.part
    echo "$(basename ${f%.*})" >> CaskPassed.part
  else
    echo -e "\033[1;31mSHA-$SHA_ALG mismatch!\033[22;0m"
    echo -e "$(basename ${f%.*}): SHA-$SHA_ALG mismatch!" >> CaskTasting.part
  fi
  #find $(brew --cache) -name "$f*" -type f -delete
  brew cask cleanup >/dev/null 2>&1
else
  echo -e "\033[1;34mno checksum\033[22;0m"
  echo -e "$(basename ${f%.*}): no checksum" >> CaskTasting.part
  echo "$(basename ${f%.*})" >> CaskNoSum.part
fi
exit $RETURNCODE
