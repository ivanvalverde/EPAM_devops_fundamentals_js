#validating if jq is installed

if ! [[ -f $(which jq) ]]
then
	echo "In order to run this script properly, you need to have the jq lib installed."
	echo "If you are a Linux user, to install jq type in a terminal: sudo apt-get install jq and press enter"
	echo "If you are a macOS user, to install jq type in a terminal: brew install jq and press enter(homebrew is required for this)."
	echo "Finally, if you are a windows user, you can download the executables here: stedolan.github.io/jq/download or if you have chocolatey just open a terminal with administrator privileges and type: chocolatey install jq."
	exit 0
fi

#validating if first argument is the path of the JSON file

if ! [[ "$1" =~ .*.json ]]
then
	echo "Error! The first argument should be the path of the JSON file you want to change. It is supposed to be in this folder's parent directory." 1>&2
	exit 64
fi

#validating if there are main properties on the file

validatingJson() {                                 
key=$(grep "$1" ../pipeline.json)
if [[ "$key" = "" ]]
then
        echo "Error! The JSON file is not in the correct structure." 1>&2
        exit 64

fi
}

validatingJson 'pipeline'
validatingJson 'stages'
validatingJson 'actions'
validatingJson 'Branch'
validatingJson 'Owner'
validatingJson 'PollForSourceChanges'

#script to create the updated JSON file

cp $1 "../pipeline-$(date +'%d-%m-%Y_%Hh%Mm%Ss').json"
cd ..
file=$(find . -type f -iname "pipeline-$(date +'%d-%m-%Y_%Hh%Mm%Ss').json" | tail -1)

overwrittingFile() {
cp temp $file
rm temp
}

jq 'del(.metadata)' $file > temp
overwrittingFile
newVersion=$(jq '.pipeline.version+1' $file)
jq --arg newVersion "$newVersion" '.pipeline.version = $newVersion' $file > temp
overwrittingFile

branchFlag="main"
ownerFlag="Thirdparty"
pollForSourceChangesFlag=false
configurationFlag="[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"none\",\"type\":\"PLAINTEXT\"}]"

while [ "${1:-}" != "" ]; do
  case $1 in
    "--branch")
	shift
	branchFlag=$1
      ;;
    "--owner")
	shift
 	ownerFlag=$1
      ;;
    "--poll-for-source-changes")
	shift
 	pollForSourceChangesFlag=$1
      ;;
    "--configuration")
	shift
	configurationFlag="[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"$1\",\"type\":\"PLAINTEXT\"}]"
	;;
  esac
shift
done

if ! [[ $branchFlag = "main" && $ownerFlag = "Thirdparty" && $pollForSourceChangesFlag = false && $configurationFlag = "[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"none\",\"type\":\"PLAINTEXT\"}]" ]]
then
jq --arg branchFlag "$branchFlag" '.pipeline.stages[0].actions[0].configuration.Branch = $branchFlag' $file > temp
overwrittingFile
jq --arg ownerFlag "$ownerFlag" '.pipeline.stages[0].actions[0].configuration.Owner = $ownerFlag' $file > temp
overwrittingFile
jq --arg pollForSourceChangesFlag "$pollForSourceChangesFlag" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pollForSourceChangesFlag' $file > temp
overwrittingFile
jq --arg configurationFlag "$configurationFlag" '.pipeline.stages[0].actions[0].configuration.EnvironmentVariables = $configurationFlag' $file > temp 
overwrittingFile
jq --arg configurationFlag "$configurationFlag" '.pipeline.stages[1].actions[0].configuration.EnvironmentVariables = $configurationFlag' $file > temp
overwrittingFile
jq --arg configurationFlag "$configurationFlag" '.pipeline.stages[2].actions[0].configuration.EnvironmentVariables = $configurationFlag' $file > temp
overwrittingFile
jq --arg configurationFlag "$configurationFlag" '.pipeline.stages[3].actions[0].configuration.EnvironmentVariables = $configurationFlag' $file > temp
overwrittingFile
fi
