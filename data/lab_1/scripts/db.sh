dir=$PWD
parentDir="$(dirname "$dir")"

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
cp "$parentDir/users.db" "$parentDir/$(date +'%d-%m-%Y')-users.db.backup"
}

restore() {
checkIfDbExists
if ! [[ -f "$parentDir/*-users.db.backup" ]]
then
	echo "No backup file found"
	exit 0
fi
local mostRecentFile=$(ls "$parentDir" -tp | grep -v /$ | head -1)
cp "$parentDir/$mostRecentFile" "$parentDir/users.db"
}

find() {
checkIfDbExists
read -p "Type an username to bring back with his/her role " requestedUser
local lines=$(cat "$parentDir/users.db")
if ! [[ "${lines,,}" == *"$requestedUser"* ]]
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

$@
