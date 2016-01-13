#!/bin/sh

DATA_FOLDER=$(dirname $(readlink -f $0))
echo $DATA_FOLDER

. ${DATA_FOLDER}/config.sh

CLEARLOG=0 # switch to delete the log in each run turn to 0 for debugging
LOG_FILE=${DATA_FOLDER}/update.log

# get recent and actual IPv4
OLDIPv4=$(cat ${DATA_FOLDER}/old.ipv4)
NEWIPv4=$(curl -s ip4.nnev.de)

# delete log file
if [ $CLEARLOG -eq 1 ] && [ -e $LOG_FILE ]; then
	rm $LOG_FILE
fi

# update the A-record
if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
    echo $NEWIPv4 > ${DATA_FOLDER}/old.ipv4
    echo "\n\nUpdating IPv4..." >> $LOG_FILE
    DATA=$(cat ${DATA_FOLDER}/nameserver.updateRecord.xml | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> $LOG_FILE
fi
