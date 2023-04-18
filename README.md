# Dynamic folders

Collection of Bash scripts that execute functionalities in folders.

## Video optmizer

Folder that watches when new videos are added to a folder and optimizes them.

### Requirements

- `inotify-tools`
- `ffmpeg`

Example in Debian.

``` sh
sudo apt install inotify-tools ffmpeg
```

### Install


``` sh
curl -o dynamic-folders-video-optimizer https://raw.githubusercontent.com/tanrax/dynamic-folders/main/dynamic-folders-video-optimizer.sh && chmod +x dynamic-folders-video-optimizer && sudo mv dynamic-folders-video-optimizer /usr/local/bin
```

### Run

``` sh
dynamic-folders-video-optimizer [folder to watch]
```

### Service

```ini
[Unit]
Description=Folder that watches when new videos are added to a folder and optimizes them.

[Service]
Restart=always
RestartSec=5
User=[user]
Group=[user]
WorkingDirectory=/home/[user]
ExecStart=dynamic-folders-video-optimizer [folder to watch]

[Install]
WantedBy=multi-user.target
```

## Development

### Check syntax

```sh
shellcheck [script]
```
