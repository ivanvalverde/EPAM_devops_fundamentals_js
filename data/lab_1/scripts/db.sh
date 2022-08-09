dir=$PWD
parentDir="$(dirname "$dir")"

help() {
local bold=$(tput bold)
local normal=$(tput sgr0)
echo "This script is used to interact with the users.db file in this parent folder"
echo "The methods used to interact with it are:"
echo ""
echo "${bold}ADD${normal}:"
echo ""
echo "Adds a line with a username and its related role in the db. The system will request a username an a role. For those fields are allowed only letters."
echo "How to use: ./db.sh add"
echo ""
echo "${bold}BACKUP${normal}:"
echo ""
echo "It creates a backup of the db at the moment this command is executed. The format of the backup is %date%-users.db.backup. The date formatting is dd/mm/YYYY"
echo "How to use: ./db.sh backup"
echo ""
echo "${bold}RESTORE${normal}"
echo ""
echo "It overwrites the db with its most recent backup."
echo "How to use: ./db.sh restore"
echo ""
echo "${bold}FIND${normal}"
echo ""
echo "Finds a user through its role or username. The system will request the user for a string to search in the db (case insensitive). If one or more users are found, all of them are printed."
echo "How to use: ./db.sh find"
echo ""
echo "${bold}LIST${normal}"
echo ""
echo "Prints an ordered list with all users contained in the db in ascending order."
echo "Available options: --inverse - prints an ordered list of all users in descending order."
echo "How to use: ./db.sh list [--inverse]"
echo ""
echo "${bold}HELP${normal}"
echo ""
echo "Prints out information regarding all available commands in the script."
echo "How to use: ./db.sh help or ./db.sh"
}

add() {
checkIfDbExists
read -p 'What will be the username? ' username
hasOnlyLetters "$username"
read -p 'Which role do you want to apply to it? ' role
hasOnlyLetters "$role"

echo "$username, $role" >> "$parentDir/users.db"
}

backup() {
checkIfDbExists
cp "$parentDir/users.db" "$parentDir/$(date +'%d-%m-%Y_%Hh%Mm%Ss')-users.db.backup"
}

restore() {
checkIfDbExists

if ! [[ $(command find .. -type f -iname "*backup" | tail -1) ]]
then
    echo "No backup file found"
	exit 0
fi
local mostRecentFile=$(command find .. -type f -iname "*backup" -printf "%f\n" | sort -n | tail -1)
cp "$parentDir/$mostRecentFile" "$parentDir/users.db"
}

find() {
checkIfDbExists
read -p "Type an username to bring back with his/her role " requestedUser
local lines=$(cat "$parentDir/users.db")
shopt -s nocasematch
if ! [[ "$lines" == *"$requestedUser"* ]]
then
	echo "User not found"
	exit 0
fi
while IFS="" read -r line || [ -n "$line" ]
do
	if [[ "${line,,}" == *"$requestedUser"* ]]; then
  		echo "$line"
	fi
done <"$parentDir/users.db"
}

list() {
local counter=0
while IFS="" read -r line || [ -n "$line" ]
do
counter=$((counter+1))
echo "$counter. $line" >> listing.txt
done <"$parentDir/users.db"
case "$1" in
	--inverse) cat listing.txt | tac;;
	*) cat listing.txt
esac
rm listing.txt
}

checkIfDbExists() {
if ! [[ -f "$parentDir/users.db" ]]
then
	read -p "It wasn't possible to find users.db. Do you want me to create one? (y - yes/n - no) " confirmation
	if [[ "$confirmation" == 'y' ]]
	then
        	touch "$parentDir/users.db"
	else
        	echo "It's not possible to keep going without users.db. Exiting program."
		exit 0
	fi
fi
}

hasOnlyLetters() {
local testString=$1
if [[ "${testString}" =~ [^a-zA-Z] ]]
then
	echo "Allowed only latin letters"
	exit 0
fi
}

case "$1" in
	"") help;;
	*)$@
esac
