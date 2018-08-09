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

    clear
    sleep 5
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

#  RPCUSER=$(pwgen -s 8 1)
#  RPCPASSWORD=$(pwgen -s 15 1)
#    echo -e "${YELLOW}rpcuser is${NC} $RPCUSER"
#    echo -e "${YELLOW}rpcpassword is${NC} $RPCPASSWORD"
#    DEFAULTUBETFOLDER="$HOME/.U-BETcoin"

    PRIV_KEY=$(U-BET-cli masternode genkey)
    echo -e "The Masternode Private Key is: ${YELLOW}$PRIV_KEY${NC}"
    U-BET-cli stop
    sleep 5

    myip=`curl ipinfo.io/ip`
    echo -e "Your U-BET Masternode (MN) Public IP Address and the Port are: ${YELLOW}$myip:$DEFAULTUBETPORT${NC}"

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

U-BETd &

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

clear

echo -e "${GREEN}Congrats! Your U-BET Masternode has been successfully installed!"
echo -e " Please go to your local U-BET wallet folder and add the required data string into the 'masternode.conf' file as per the following pattern:"
echo -e "${YELLOW}MN1 Masternode_Public_IP:20189 Masternode_Private_Key Transaction_ID Transaction_Index"
echo -e "${NC}Your U-BET Masternode (MN) Public IP Address and the Port are: ${YELLOW}$myip:$DEFAULTUBETPORT"
echo -e "${NC} Your U-BET Masternode (MN) Private Key is: ${YELLOW}$PRIV_KEY"
echo -e " ${GREEN}Right after you need to save the 'masternode.conf' file. Then you need to wait for at least 15 confirmations for the 2,500 U-BET coins collateral transaction and then restart the wallet (completely close and then run your wallet again). Then go to the 'Masternode' tab in the wallet and start your U-BET masternode.${NC} "
