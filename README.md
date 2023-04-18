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
curl -o dynamic-folders-video-optimizer https://raw.githubusercontent.com/tanrax/dynamic-folders/main/dynamic-folders-video-optimizer.sh && chmod +x dynamic-folders-video-optimizer && sudo mv dynamic-folders-video-optimizer /usr/local/bin && echo "🎉 Successfully installed! 🎉"
```

Test

``` sh
dynamic-folders-video-optimizer --help
```

### Run

``` sh
dynamic-folders-video-optimizer --folder [folder to watch]
```

Example.

``` sh
mkdir optmizer
dynamic-folders-video-optimizer --folder optimizer
```

And leave a video that you want to optimize in the folder `optimizer`.

### Service

Create a file in `/etc/systemd/system/dynamic-folders-video-optimizer.service` with the following content.


```ini
[Unit]
Description=Folder that watches when new videos are added to a folder and optimizes them.

[Service]
Restart=always
RestartSec=5
User=[user]
ExecStart=dynamic-folders-video-optimizer --folder [folder to watch]

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
sudo systemctl enable dynamic-folders-video-optimizer
sudo systemctl start dynamic-folders-video-optimizer
```

### Cron

Open.

``` sh
crontab -e
```

Add to document.

``` sh
@reboot dynamic-folders-video-optimizer >/dev/null 2>&1 &
```

## Development

### Check syntax

```sh
shellcheck [script]
```
