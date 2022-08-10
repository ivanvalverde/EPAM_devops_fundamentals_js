if ! [[ -f $(which jq) ]]
then
        sudo apt-get install jq
fi
cd ..
cp ./pipeline.json "./pipeline-$(date +'%d-%m-%Y_%Hh%Mm%Ss').json"
file=$(find . -type f -iname "pipeline-*.json" | tail -1)

overwrittingFile() {
cp temp $file
rm temp
}

jq 'del(.metadata)' $file > temp
overwrittingFile
newVersion=$(jq '.pipeline.version+1' $file)
jq --arg newVersion "$newVersion" '.pipeline.version = $newVersion' $file > te>
overwrittingFile

