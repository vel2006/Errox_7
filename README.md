# ERROX_7 IS NOT DESIGNED TO BE MALWARE, IT IS DESIGNED TO BE FOR REMOTE MONITORING FOR NETWORK ADMINS

# Errox_7
Errox_7 is a collection of Bash files (.sh) which are used to make up a one time romote access program for Linux distributions. Current supported client side flavors are: Ubuntu
Errox_7 is designed to be as light weight on the client side as possible, while still maintaining the core properties needed for software of it's type

Errox_7.sh:
  Errox_7.sh is the client side file.
  1) Gets the target's ipv4 address
  2) Sends the user's ip address to the host server
  3) Waits for a response on the selected port
  4) If gets a valid response, it will start to listen for incoming commands through nc on specified port

Errox_7Server.sh:
  Errox_7Server.sh is the server side file.
  Listen:
  1) Uses nc to listen for any incoming data on the port that is set to default 80, but can be changed by hand
  2) Extracts the incoming data and converts it into an ip address and adds it to a file (only one at a time can be within it, working on expanding to a .csv file)
  3) Waiting so the latency from client to server can be solved
  4) Sends a confermation message for the client to start listening for any commands
  Command:
  1) Takes in the wanted command
  2) Checks the clients.txt file, if it doesnt exist it will end and prompt for using Listen first
  3) Formats the clients array (left in for the update having a clients.csv file instead)
  4) Sends the command to all clients within the clients.txt file
  CreateErrox:
  1) Makes the Errox_7.sh file, change the port that nc uses to your liking
