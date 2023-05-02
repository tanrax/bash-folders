# Bash folders

![Bash folder brand](assets/social.webp)

Collection of Bash scripts to execute functionalities in folders, such as optimizing videos, unzipping files, converting images, etc.

- [Video optimizer](#video-optimizer)
- [Battery hook](#battery-hook)
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

## Battery hook

Folder with scripts to be launched in different battery states.

The filename of the scripts must be:

- `discharging`: When the battery is in use.
- `charging`: When the battery is charging.
- `low`: When it reaches the low percentage. Default 15.
- `high`: When it reaches the high percentage. Default 85.
- `full`: When the battery is full.

They must have **execution permissions**. If any of them do not exist, they will be ignored.

### Install


``` sh
curl -o bash-folders-battery-hook https://raw.githubusercontent.com/tanrax/bash-folders/main/bash-folders-battery-hook.sh && chmod +x bash-folders-battery-hook && sudo mv bash-folders-battery-hook /usr/local/bin && echo "🎉 Successfully installed! 🎉"
```

Test

``` sh
bash-folders-battery-hook --help
```

### Run

``` sh
bash-folders-battery-hook --folder [folder path]
```

Example.

``` sh
mkdir battery-scripts

touch battery-scripts/discharging
chmod +x battery-scripts/discharging
touch battery-scripts/charging
chmod +x battery-scripts/charging
touch battery-scripts/low
chmod +x battery-scripts/low
touch battery-scripts/high
chmod +x battery-scripts/high
touch battery-scripts/full
chmod +x battery-scripts/full

bash-folders-battery-hook --folder battery-scripts
```

### Start at operating system startup

#### Option 1: Service

Create a file in `/etc/systemd/system/bash-folders-battery-hook.service` with the following content.


```ini
[Unit]
Description=Folder with scripts to be launched in different battery states.

[Service]
Restart=always
RestartSec=5
User=[user]
ExecStart=bash-folders-battery-hook --folder [folder path]

[Install]
WantedBy=multi-user.target
```

Edit it to your needs.

Now you will need the script to run every so often to check the battery status. The best solution is to create a `timer`.

Create a file in `/etc/systemd/system/bash-folders-battery-hook.timer` with the following content.

```ini
[Unit]
Description=Folder with scripts to be launched in different battery states every minute.

[Timer]
OnCalendar=*-*-* *:*:00
Persistent=true

[Install]
WantedBy=timers.target
```

Recharge services.

``` sh
sudo systemctl daemon-reload
```

And activate it.

``` sh
sudo systemctl enable bash-folders-battery-hook.timer
sudo systemctl start bash-folders-battery-hook.timer
```

#### Option 2: Cron

Open.

``` sh
crontab -e
```

Add to document.

``` sh
@reboot * * * * * bash-folders-battery-hook --folder [folder path]
```

---

## Development

### Check syntax

```sh
shellcheck [script]
```
