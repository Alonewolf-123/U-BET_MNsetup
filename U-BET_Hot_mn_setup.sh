TMP_FOLDER=$(mktemp -d)
CONFIG_FILE="U-BETcoin.conf"
UBET_DAEMON="/usr/local/bin/U-BETd"
UBET_REPO="https://github.com/U-BETcoinmn/U-BET-1.0.1"
DEFAULTUBETPORT=20189
DEFAULTUBETUSER="U-BET"
DEFAULTUBETFOLDER="$HOME/.U-BETcoin"

NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $UBET_DAEMON)" ] || [ -e "$U-BET_DAEMOM" ] ; then
  echo -e "${GREEN}\c"
  read -e -p "U-BET is already installed. Do you want to add another MN? [Y/N]" NEW_U-BET
  echo -e "{NC}"
  clear
else
  NEW_UBET="new"
fi
echo -e "${NC}"
apt-get update
apt-get upgrade
apt-get install libboost-system1.58.0
apt-get install libboost-filesystem1.58.0
apt-get install libboost-program-options1.58.0
apt-get install libboost-thread1.58.0
apt-get install libboost-chrono1.58.0
apt-get install libminiupnpc10
apt-get install libzmq5
apt-get install libevent-2.0-5
apt-get install libevent-pthreads-2.0-5
apt-get install pwgen
apt-get install bc

    echo -e "Download the debian package from U-BET git.."
    wget https://github.com/KiPa-SuJi/U-BET-Core/releases/download/U-BET_1.0.0.1/U-BET-setup_1.0-1.deb
    sleep 2
    dpkg --install U-BET-setup_1.0-1.deb
    sleep 1
    rm U-BET-setup_1.0-1.deb
    U-BET-cli stop
    sleep 15
  RPCUSER=$(pwgen -s 8 1)
  RPCPASSWORD=$(pwgen -s 15 1)
    echo -e "${YELLOW}rpcuser is${NC} $RPCUSER"
    echo -e "${YELLOW}rpcpassword is${NC} $RPCPASSWORD"
    WALLET_FILE="wallet.dat"

if [ -d "$DEFAULTUBETFOLDER" ]; then
	cd $DEFAULTUBETFOLDER
	if [ -f $WALLET_FILE ]; then
   		cp $WALLET_FILE $HOME/$WALLET_FILE
		rm -rf $DEFAULTUBETFOLDER
		mkdir $DEFAULTUBETFOLDER
		cp $HOME/$WALLET_FILE $DEFAULTUBETFOLDER/$WALLET_FILE
		rm $HOME/$WALLET_FILE
	else
		rm -rf $DEFAULTUBETFOLDER
		mkdir $DEFAULTUBETFOLDER
	fi
fi
	touch $DEFAULTUBETFOLDER/$CONFIG_FILE
cat << EOF > $DEFAULTUBETFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
txindex=1

addnode=183.182.105.91
addnode=183.182.104.121
addnode=45.76.37.150
addnode=45.76.85.141


EOF

    U-BETd &
    sleep 5

    clear
    echo -e "${GREEN}Please send the collateral of 2,500 U-BET coins to the following MN address:${NC}"
    ADDRESS=$(U-BET-cli getaccountaddress 0)
    echo -e "${YELLOW}$ADDRESS${NC}"
    BALANCE=0
    COLLATERAL=2500.0
    BALANCE=$(U-BET-cli getbalance)
    if (( $(echo "$BALANCE < $COLLATERAL" | bc -l) )); then
        echo -e "The current balance is ${YELLOW}$BALANCE${NC}"
        echo -e "${GREEN}Please wait till the balance is 2,500 U-BET coins!${NC}"
    fi
    chrlen=0
    minlen=20
    while (( $(echo "$chrlen < $minlen" | bc -l) )); do
	outputs=$(U-BET-cli masternode outputs)
	chrlen=${#outputs}
        BALANCE=$(U-BET-cli getbalance)
        sleep 2
    done
    echo -e "The current balance is ${GREEN}$BALANCE${NC}"




#  RPCUSER=$(pwgen -s 8 1)
#  RPCPASSWORD=$(pwgen -s 15 1)
#    echo -e "${YELLOW}rpcuser is${NC} $RPCUSER"
#    echo -e "${YELLOW}rpcpassword is${NC} $RPCPASSWORD"
#    DEFAULTUBETFOLDER="$HOME/.U-BETcoin"

    PRIV_KEY=$(U-BET-cli masternode genkey)
    echo -e "Masternode PrivKey is ${YELLOW}$PRIV_KEY${NC}"

    myip=`curl ipinfo.io/ip`

    MASTERNODE_CONFIG_FILE="masternode.conf"
    MN_NAME="my_MN"
  outputs=$(U-BET-cli masternode outputs)
  a=${outputs#*\"}
  tr_hash=${a%%\"*}
  echo -e "Transaction hash is ${YELLOW}$tr_hash${NC}"
  b=${a#*\"}
  b=${b#*\"}
  INDEX=${b%%\"*}

U-BET-cli stop
sleep 15

  cat << EOF > $DEFAULTUBETFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
txindex=1
#----
masternode=1
masternodeprivkey=$PRIV_KEY
masternodeaddr=$myip:$DEFAULTUBETPORT

addnode=183.182.105.91
addnode=183.182.104.121
addnode=45.76.37.150
addnode=45.76.85.141

EOF

  cat << EOF > $DEFAULTUBETFOLDER/$MASTERNODE_CONFIG_FILE
# Masternode config file
# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index
# Example: mn1 127.0.0.2:20189 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0
$MN_NAME $myip:$DEFAULTUBETPORT $PRIV_KEY $tr_hash $INDEX

EOF
    
U-BETd &
sleep 5

cat << EOF | sudo tee /etc/systemd/system/U-BET@root.service
[Unit]
Description=U-BET daemon
[Service]
User=root
Type=forking
ExecStart=/usr/local/bin/U-BETd -daemon
Restart=always
RestartSec=20
[Install]
WantedBy=default.target
EOF
sudo systemctl enable U-BET@root.service
sudo systemctl start U-BET@root.service 

if [ -d "$DEFAULTUBETFOLDER" ]; then
	cd $DEFAULTUBETFOLDER
	if [ -d "$HOME/Backup" ]; then
		backup=$HOME/Backup
	else
		mkdir $HOME/Backup
	fi

	if [ -f $WALLET_FILE ]; then
		timestamp=$(date +%s)
   		cp $WALLET_FILE $HOME/Backup/$WALLET_FILE-$timestamp
	fi
fi

clear
sleep 5

echo -e "${GREEN}Please wait for 15 confirmations for the U-BET MN collateral transaction to get cleared!${NC}"
confirmations=0
prev=0
 while (( $(echo "$confirmations < 15" | bc -l) )); do
	transaction=$(U-BET-cli gettransaction $tr_hash)
	confirm="confirmations"
	temp=`echo $transaction | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $confirm`
	confirm=${temp##*|}
	confirmations=${confirm#*confirmations : }
	if [ "$prev" -lt "$confirmations" ]; then
		prev=$confirmations
		echo -e "${GREEN}The current number of confirmations is ${YELLOW}$confirmations!${NC}"
	fi
        sleep 2
done

U-BET-cli stop
sleep 15
U-BETd &
sleep 5
clear

MNSYNCSTAT=1

echo -e "${GREEN}Your wallet was backed up automatically to the following directory on this VPS:${NC}"
echo -e "${YELLOW} $HOME/Backup/$WALLET_FILE-$timestamp"
echo -e "${GREEN}Please wait till the MN synchronization is complete!${NC}"
while [ $MNSYNCSTAT -lt 999 ]; do
    sleep 1
    output=$(U-BET-cli mnsync status)
    a=${output#*RequestedMasternodeAssets\" : }
    MNSYNCSTAT=${a%,*}
    printf "."
done


echo -e "${GREEN} Your wallet made a backup to the following path:${NC}"
echo -e "${YELLOW} $HOME/Backup/$WALLET_FILE-$timestamp"
echo -e "${GREEN}Please wait till the MN synchronization is complete!${NC}"
echo -e "Your U-BET Masternode (MN) Public IP Address and the Port are: ${YELLOW}$myip:$DEFAULTUBETPORT${NC}"
echo -e "Masternode PrivKey is ${YELLOW}$PRIV_KEY${NC}"
echo -e "Transaction hash is ${YELLOW}$tr_hash${NC}"
echo -e "${GREEN} "
U-BET-cli masternode start-all
sleep 1
U-BET-cli masternode start-alias $MN_NAME
sleep 1
U-BET-cli masternode start
echo -e "${NC} "

echo -e "${GREEN}Congrats! Your U-BET Masternode has been successfully installed!${NC}"


