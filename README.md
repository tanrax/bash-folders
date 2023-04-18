# Dynamic folders

Collection of Bash scripts that execute functionalities in folders.

## Video to mp4

### Install

### Run

### Service

```sh
wget /etc/systemd/system/github-runner-glosa.service
curl -o maza https://raw.githubusercontent.com/tanrax/maza-ad-blocking/master/maza && chmod +x maza && sudo mv maza /usr/local/bin
```

```ini
[Unit]
Description=Github runner glosa
After=network.target

[Service]
Restart=always
RestartSec=5
User=github
Group=github
Restart=always
WorkingDirectory=/home/github/actions-runner
ExecStart=/home/user/

[Install]
WantedBy=multi-user.target
```

## Development

### Check syntax

```sh
shellcheck [script]
```
