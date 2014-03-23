brew detox
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
for f in $FILES
do
  echo "==> Downloading and checking ${f%.*}"
  brew cask audit --download "${f%.*}"
done
brew detox
