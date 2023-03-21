#!/bin/bash

#sudo apt install inotify-tools ffmpeg
# @reboot /ruta/a/tu/script.sh >/dev/null 2>&1 &
# Carpeta de destino
WATCH_FOLDER="/ruta/a/la/carpeta"

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
            # Convierte el archivo a formato MP4
            ffmpeg -i "$WATCH_FOLDER/$filename" -codec:v libx264 -preset slow -crf 18 -codec:a copy "$WATCH_FOLDER/${filename%.*}.mp4"
            echo "Archivo convertido: ${filename%.*}.mp4"
        else
            echo "Archivo ignorado: $filename"
        fi
    fi
done
