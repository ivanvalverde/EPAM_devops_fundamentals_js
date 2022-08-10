sudo apt-get install jq
cd ..
cp ./pipeline.json "./pipeline-$(date +'%d-%m-%Y_%Hh%Mm%Ss').json"
file=$(find . -type f -iname "pipeline-*.json" | tail -1)
jq 'del(.metadata)'$file
jq '.pipeline.version + 1'
 
