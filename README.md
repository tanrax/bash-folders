# Bash folders

Collection of Bash scripts to execute functionalities in folders, such as optimizing videos, unzipping files, converting images, etc.

- [Video optimizer](#video-optimizer)
- [Decompress files](#decompress-files)

---

## Video optimizer

Folder that watches when new videos are added and optimizes them.

### Requirements

- `inotify-tools`
- `ffmpeg`

Example in Debian.

``` sh
sudo apt install inotify-tools ffmpeg
```

### Install


``` sh
curl -o bash-folders-video-optimizer https://raw.githubusercontent.com/tanrax/bash-folders/main/bash-folders-video-optimizer.sh && chmod +x bash-folders-video-optimizer && sudo mv bash-folders-video-optimizer /usr/local/bin && echo "🎉 Successfully installed! 🎉"
```

Test

``` sh
bash-folders-video-optimizer --help
```

### Run

``` sh
bash-folders-video-optimizer --folder [folder to watch]
```

Example.

``` sh
mkdir optimizer
bash-folders-video-optimizer --folder optimizer
```

And leave a video that you want to optimize in the folder `optimizer`.

### Start at operating system startup

#### Option 1: Service

Create a file in `/etc/systemd/system/bash-folders-video-optimizer.service` with the following content.


```ini
[Unit]
Description=Folder that watches when new videos are added and optimizes them.

[Service]
Restart=always
RestartSec=5
User=[user]
ExecStart=bash-folders-video-optimizer --folder [folder to watch]

[Install]
WantedBy=multi-user.target
```

Edit it to your needs.

Recharge services.

``` sh
sudo systemctl daemon-reload
```

And activate it.

``` sh
sudo systemctl enable bash-folders-video-optimizer
sudo systemctl start bash-folders-video-optimizer
```

#### Option 2: Cron

Open.

``` sh
crontab -e
```

Add to document.

``` sh
@reboot bash-folders-video-optimizer --folder [folder to watch] >/dev/null 2>&1 &
```

---

## Development

### Check syntax

```sh
shellcheck [script]
```
