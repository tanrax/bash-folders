#!/bin/bash

# Requirements: sudo apt install inotify-tools ffmpeg
# Enable, cron: @reboot /path/script.sh >/dev/null 2>&1 &
# Carpeta de destino
WATCH_FOLDER=$argv[1]

# Extensiones a monitorear
EXTENSIONS=("mkv" "mp4" "avi" "mov")

# Configura inotify para monitorear la carpeta de destino
inotifywait -m -e create --format '%f' "$WATCH_FOLDER" |
while read filename; do
    # Obtiene la extensión del archivo
    extension="${filename##*.}"

    # Verifica si la extensión está en la lista de extensiones
    if [[ " ${EXTENSIONS[@]} " =~ " ${extension} " ]]; then
        # Verifica si el nombre del archivo comienza con "optimized"
        if [[ "$filename" != optimized* ]]; then
	    notify-send "Archivo detectado: $filename. Iniciando conversión..."
            # Convierte el archivo a formato MP4
            ffmpeg -i "$WATCH_FOLDER/$filename" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$WATCH_FOLDER/optimized_${filename%.*}.mp4"
            notify-send "Archivo convertido: optimized_${filename%.*}.mp4"
        else
            echo "Archivo ignorado: $filename"
        fi
    fi
done
