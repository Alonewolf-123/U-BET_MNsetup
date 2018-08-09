CONFIG_FILE="U-BETcoin.conf"
UBET_DAEMON="/usr/local/bin/U-BETd"
UBET_REPO="https://github.com/U-BETcoinmn/U-BET-1.0.1"
DEFAULTUBETPORT=20189
DEFAULTUBETUSER="U-BET"
DEFAULTUBETFOLDER="$HOME/.U-BETcoin"
NODEIP=$(curl -s4 icanhazip.com)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}$0 must be run as root.${NC}"
  exit 1
fi
echo -e "${NC}"
sudo apt -y update && sudo apt -y install build-essential libssl-dev libdb++-dev && sudo apt -y install libboost-all-dev libcrypto++-dev libqrencode-dev && sudo apt -y install libminiupnpc-dev libgmp-dev libgmp3-dev autoconf && sudo apt -y install autogen automake libtool autotools-dev pkg-config && sudo apt -y install bsdmainutils software-properties-common && sudo apt -y install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt-get update && sudo apt-get install libdb4.8-dev libdb4.8++-dev -y && apt install -y pwgen

echo -e "Download the debian package from U-BET git.."
  wget https://github.com/KiPa-SuJi/U-BET-Core/releases/download/U-BET_1.0.0.1/U-BET-setup_1.0-1.deb
  sleep 3
  dpkg --install U-BET-setup_1.0-1.deb
  sleep 2
  rm U-BET-setup_1.0-1.deb

U-BET-cli stop
sleep 5
RPCUSER=$(pwgen -s 8 1)
RPCPASSWORD=$(pwgen -s 15 1)
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
addnode=66.42.58.116
addnode=66.42.63.73
addnode=45.76.37.150
addnode=45.76.85.141

EOF
U-BETd -daemon
sleep 10
PRIV_KEY=$(U-BET-cli masternode genkey)
U-BET-cli stop
sleep 10
myip=`curl ipinfo.io/ip`
cat << EOF | tee $DEFAULTUBETFOLDER/$CONFIG_FILE
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
#----
addnode=66.42.58.116
addnode=66.42.63.73
addnode=45.76.37.150
addnode=45.76.85.141
EOF
clear
sleep 10
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
sleep 2
U-BET-cli stop
sleep 2
U-BETd -daemon -reindex
clear
echo -e "${GREEN}Congrats! Your U-BET Masternode has been successfully installed!"
echo -e " Please go to your local U-BET wallet folder and add the required data string into the 'masternode.conf' file as per the following pattern:"
echo -e "${RED}MN1 Masternode_Public_IP:20189 Masternode_Private_Key Transaction_ID Transaction_Index"
echo -e "${NC}Your U-BET Masternode (MN) Public IP Address and the Port are: ${GREEN}$myip:$DEFAULTUBETPORT"
echo -e "${NC} Your U-BET Masternode (MN) Private Key is: ${GREEN}$PRIV_KEY"
echo -e "Your U-BET Masternode (MN) Config file is:" 
echo -e "${GREEN}MN01 $myip:$DEFAULTUBETPORT$ $PRIV_KEY${NC}"
echo -e "You must add Masternode_Private_Key Transaction_ID Transaction_Index"
echo -e " ${GREEN}Right after you need to save the 'masternode.conf' file. Then you need to wait for at least 15 confirmations for the 2,500 U-BET coins collateral transaction and then restart the wallet (completely close and then run your wallet again). Then go to the 'Masternode' tab in the wallet and start your U-BET masternode.${NC} "
