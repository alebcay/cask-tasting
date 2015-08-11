#!/usr/bin/env bash
echo "Preparing for check..."
cd ~/cask-tasting
git checkout master
brew sync
[ -e "CaskTasting.part" ] && rm "CaskTasting.part"
[ -e "CaskPassed.part" ] && rm "CaskPassed.part"
[ -e "CaskDLError.part" ] && rm "CaskDLError.part"
[ -e "CaskSumError.part" ] && rm "CaskSumError.part"
[ -e "CaskNoSum.part" ] && rm "CaskNoSum.part"

STARTTIME=$(date)
echo "Check started at $STARTTIME"
#FILES=/usr/local/Library/Taps/caskroom/homebrew-cask/Casks/*.rb

#parallel -k --progress ./parallelcheck.sh {} ::: $FILES
ppss -d /usr/local/Library/Taps/caskroom/homebrew-cask/Casks -c './parallelcheck.sh '

sort ./CaskTasting.part -o ./CaskTasting.part
echo "Check started at $STARTTIME" | cat - ./CaskTasting.part > tmp.txt

echo "Check finished at $(date)" >> ./tmp.txt
echo "Check finished at $(date)"

mv tmp.txt CaskTasting.txt
mv CaskPassed.part CaskPassed.txt
mv CaskSumError.part CaskSumError.txt
mv CaskNoSum.part CaskNoSum.txt

rm -r ppss_dir
ppss -d /Library/Caches/Homebrew -c 'rm '
rm -r ppss_dir
echo "Sending data to master..."
git add .
git commit -m "Cask taster reporting for duty: $(date)"
git gc --aggressive
git push
