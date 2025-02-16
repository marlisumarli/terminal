#!/bin/bash

cd $HOME

echo "Stopping any process using port 8003..."
PID=$(lsof -ti :8003)
if [ -n "$PID" ]; then
  echo "Killing process with PID: $PID"
  kill -9 $PID
else
  echo "No process found using port 8003."
fi

echo "Stopping any DCDND service..."
pkill -f dcdnd || true

echo "Creating $HOME/pipe-network folder..."
mkdir -p $HOME/pipe-network

echo "Please enter the link to the v2 binary download from email (must start with https):"
binary_url="https://dl.pipecdn.app/v0.2.5/pop"

echo "Downloading pop binary..."
wget -O $HOME/pipe-network/pop "$binary_url"
chmod +x $HOME/pipe-network/pop
echo "Binary downloaded and made executable."

RAM=8
DISK=100
PUBKEY="Bt3LA755h6XVZKdaJTASDzL1QxwonBCRKr13CKwcWDEw"

if [ "$RAM" -lt 4 ]; then
  echo "RAM must be at least 4GB. Exiting."
  exit 1
fi

if [ "$DISK" -lt 100 ]; then
  echo "Disk space must be at least 100GB. Exiting."
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/pipe.service"
echo "Creating $SERVICE_FILE..."

cat <<EOF | tee $SERVICE_FILE > /dev/null
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=$USER
ExecStart=$HOME/pipe-network/pop \
    --ram=$RAM \
    --pubKey $PUBKEY \
    --max-disk $DISK \
    --cache-dir $HOME/pipe-network/download_cache
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node
WorkingDirectory=$HOME/pipe-network

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon and starting pipe service..."

docker run -d --name pipe-container \
  --restart unless-stopped \
  -e RAM=8 \
  -e DISK=100 \
  -e PUBKEY="Bt3LA755h6XVZKdaJTASDzL1QxwonBCRKr13CKwcWDEw" \
  pipe-network