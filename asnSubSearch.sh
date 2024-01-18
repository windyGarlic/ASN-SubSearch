#!/bin/bash

while getopts ":d:a:h" opt; do
  case $opt in
    d)
      DOMAIN="$OPTARG"
      ;;
    a)
      ASN="$OPTARG"
      ;;
    h)
      echo "Usage: $0 -d <domain> -a <ASN>"
      echo "Options:"
      echo "  -d  Domain name (required)"
      echo "  -a  ASN (optional but preferred)"
      echo "  -h  Display this help menu"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Validate required options
if [ -z "$DOMAIN" ]; then
  echo "Error: Domain (-d) is required. Use -h for help."
  exit 1
fi


# Get asn data list 	(Uncomment if you dont already have the ASN data)
#wget https://iptoasn.com/data/ip2asn-v4.tsv.gz .
#gunzip ip2asn-v4.tsv.gz


ip_to_int() {
    local ip="$1"
    IFS=. read -r i1 i2 i3 i4 <<< "$ip"
    echo "$(( (i1<<24) + (i2<<16) + (i3<<8) + i4 ))"
}

int_to_ip() {
    local int="$1"
    echo "$(( (int>>24)&255 )).$(( (int>>16)&255 )).$(( (int>>8)&255 )).$(( int&255 ))"
}


# Get IP range for specified companies ASN 
# (Maybe also add grep for country to limit results, this may miss some).
COMPANY=$(echo $DOMAIN | awk -F "." '{print$1}')

if [[ $ASN -eq '' ]]; then
	cat ip2asn-v4.tsv  | grep -i $COMPANY | awk -F " " '{print$1" "$2}' >> $COMPANY.ipRange
else
	cat ip2asn-v4.tsv  | grep -i $ASN | grep -i $COMPANY | awk -F " " '{print$1" "$2}' >> $COMPANY.ipRange
fi 

# Checks for asn in data and returns ip-range. Will prompt user to enter company name if no ranges found. 
if [[ -s $COMPANY.ipRange ]]; then
    echo '[+] Found IP ranges'
    while read line; do
        start_ip=$(echo $line | awk -F " " '{print $1}')
        end_ip=$(echo $line | awk -F " " '{print $2}')
        start_int=$(ip_to_int "$start_ip")
        end_int=$(ip_to_int "$end_ip")

        for ((int = start_int; int <= end_int; int++)); do
            current_ip=$(int_to_ip "$int")
            echo "$current_ip" >> $COMPANY.ipList
        done
    done < $COMPANY.ipRange
    else
    echo "[-] Could not find any IP range searching for $COMPANY."
    read -p "Would you like to provide a new company name? (Y/n): " CHOICE
    
    if [[ "$CHOICE" == 'n' ]]; then
        echo "Exiting"
        rm "$COMPANY.ipRange"
        exit 1 
    elif [[ "$CHOICE" == 'y' ]]; then 
        read -p "Enter the new company name to search for: " COMPANY
        cat ip2asn-v4.tsv | grep -i $ASN | grep -i $COMPANY | awk -F " " '{print$1" "$2}' >> "$COMPANY.ipRange"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi


    if [[ -s $COMPANY.ipRange ]]; then
    echo '[+] Found IP ranges'
    while read line; do
        start_ip=$(echo $line | awk -F " " '{print $1}')
        end_ip=$(echo $line | awk -F " " '{print $2}')
        start_int=$(ip_to_int "$start_ip")
        end_int=$(ip_to_int "$end_ip")

        for ((int = start_int; int <= end_int; int++)); do
            current_ip=$(int_to_ip "$int")
            echo "$current_ip" >> $COMPANY.ipList
        done
    done < $COMPANY.ipRange
    else
        echo 'Still not found. Exiting'
        exit 1
    fi
fi

# Creates list of all IP's contained in range
for line in $(cat $COMPANY.ipRange); do
    start_ip=$(echo $line | awk -F " - " '{print $1}')
    end_ip=$(echo $line | awk -F " - " '{print $2}')
    start_int=$(ip_to_int "$start_ip")
    end_int=$(ip_to_int "$end_ip")

    for ((int = start_int; int <= end_int; int++)); do
        current_ip=$(int_to_ip "$int")
        echo "$current_ip" >> $COMPANY.ipList
    done
done 

cat $COMPANY.ipList | hakip2host | sort | uniq > $DOMAIN.newSubs.tmp 
cat $DOMAIN.newSubs.tmp | awk -F " " '{print$3}' | sort | uniq > $DOMAIN.newSubs.sub 
cat $DOMAIN.newSubs.sub | grep -v "*" | dnsx -silent > $COMPANY.newSubs

rm $DOMAIN.newSubs.sub 
rm $DOMAIN.newSubs.tmp 
echo '[+] new subdomains found and stored as ' $COMPANY'.newSubs' 
cat $COMPANY.newSubs
