brew detox
FILES=/usr/local/Library/Taps/phinze-cask/Casks/*.rb
for f in $FILES
do
  brew cask audit --download "${f%.*}"
done
brew detox
