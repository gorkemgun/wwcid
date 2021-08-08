#!/bin/bash
if [ ! -f "/etc/cloak/ckserver.json" ] && [ ! -f "/etc/cloak/ckclient.json" ]
then
	[ -z ${CK_PORT+x} ] && exit
	[ -z ${CK_WEB_ADDR+x} ] && exit
	[ -z ${CK_PROXY_NAME+x} ] && exit
	[ -z ${CK_PROXY_ADDR+x} ] && exit
	[ -z ${CK_PROXY_METHOD+x} ] && exit
	[ -z ${CK_CRYPT+x} ] && exit
	num_regex='^[0-9]+$'

	PROXY_BOOK="\"$CK_PROXY_NAME\": [ \"$CK_PROXY_METHOD\", \"$CK_PROXY_ADDR\" ]"

	function WriteClientFile() {
		echo "{
		\"ProxyMethod\":\"$CK_PROXY_NAME\",
		\"EncryptionMethod\":\"$CK_CRYPT\",
		\"UID\":\"$ckbuid\",
		\"PublicKey\":\"$ckpub\",
		\"ServerName\":\"$CK_WEB_ADDR\",
		\"NumConn\":4,
		\"BrowserSig\":\"chrome\",
		\"StreamTimeout\": 300
	}" >>"ckclient.json"
	}

	if ! [[ $CK_PORT =~ $num_regex ]]; then #Check if the port is valid
		echo "$(tput setaf 1)Error:$(tput sgr 0) The input is not a valid number"
		exit 1
	fi
	if [ "$CK_PORT" -gt 65535 ]; then
		echo "$(tput setaf 1)Error:$(tput sgr 0): Number must be less than 65536"
		exit 1
	fi
	 
	mkdir /etc/cloak
	cd /etc/cloak || exit 1

	ckauid=$(ck-server -u)
	ckbuid=$(ck-server -u)
	IFS=, read ckpub ckpv <<<$(ck-server -k)

	echo "{
	  \"ProxyBook\": {
		$PROXY_BOOK
	  },
	  \"BypassUID\": [
		\"$ckbuid\"
	  ],
	  \"BindAddr\":[\":$CK_PORT\"],
	  \"RedirAddr\": \"$CK_WEB_ADDR\",
	  \"PrivateKey\": \"$ckpv\",
	  \"AdminUID\": \"$ckauid\",
	  \"DatabasePath\": \"userinfo.db\",
	  \"StreamTimeout\": 300
	}" >>ckserver.json

	WriteClientFile

	ck-server -c /etc/cloak/ckserver.json
else
	ck-server -c /etc/cloak/ckserver.json
fi
