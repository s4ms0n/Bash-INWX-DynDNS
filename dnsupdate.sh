#!/bin/bash

# config parameter
USERNAME="" # INWX USERNAME
PASSWORD="" # INWX PASSWORD
DNSIDv4="" # DNS Entry ID (A-record)
DNSIDv6="" # DNS Entry ID (AAAA-record)
APIHOST="https://api.domrobot.com/xmlrpc/" # API URL from inwx.de
CLEARLOG=1 # switch to delete the log in each run turn to 0 for debugging
DATA_FOLDER="."
LOG_FILE=${DATA_FOLDER}/update.log
# get recent and actual IPv4/IPv6
OLDIPv4=$(cat ${DATA_FOLDER}/old.ipv4)
OLDIPv6=$(cat ${DATA_FOLDER}/old.ipv6)
NEWIPv4=$(curl -s ip4.nnev.de)
NEWIPv6=$(curl -s ip6.nnev.de)


# delete log file
if [ $CLEARLOG -eq 1 ] && [ -e $LOG_FILE ]; then
	rm $LOG_FILE
fi

# update the A-record
if [ ! "$OLDIPv4" == "$NEWIPv4" ]; then
    echo $NEWIPv4 > ${DATA_FOLDER}/old.ipv4
    echo "\n\nUpdating IPv4..." >> $LOG_FILE
    DATA=$(cat ${DATA_FOLDER}/update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv4/g;s/%NEWIP%/$NEWIPv4/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> $LOG_FILE
fi

# update the AAAA-record
if [ ! "$OLDIPv6" == "$NEWIPv6" ]; then
    echo $NEWIPv6 > ${DATA_FOLDER}/old.ipv6
    echo "\n\nUpdating IPv6..." >> $LOG_FILE
    DATA=$(cat ${DATA_FOLDER}/update.api | sed "s/%PASSWD%/$PASSWORD/g;s/%USER%/$USERNAME/g;s/%DNSID%/$DNSIDv6/g;s/%NEWIP%/$NEWIPv6/g")
    curl  -s -X POST -d "$DATA" "$APIHOST" --header "Content-Type:text/xml" >> $LOG_FILE
fi

