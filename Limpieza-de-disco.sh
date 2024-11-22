#!/bin/bash

# Obtener la ruta del directorio donde se encuentra el script
script_dir=$(dirname "$0")

# Directorio temporal donde se generarán los archivos
temp_dir="$script_dir/temp"

# Crear el directorio temporal si no existe
mkdir -p "$temp_dir"

# Función para convertir tamaños de archivo a bytes
convert_to_bytes() {
    local unit="$1"
    local size="$2"
    case "$unit" in
        B)
            echo "$size"
            ;;
        KB)
            echo "$(( size * 1024 ))"
            ;;
        MB)
            echo "$(( size * 1024 * 1024 ))"
            ;;
        GB)
            echo "$(( size * 1024 * 1024 * 1024 ))"
            ;;
        TB)
            echo "$(( size * 1024 * 1024 * 1024 * 1024 ))"
            ;;
        *)
            echo "Unidad no válida. Saliendo del script." >&2
            exit 1
            ;;
    esac
}

# Preguntar al usuario la unidad y el tamaño de los archivos a generar
read -p "Especifique la unidad de tamaño (B, KB, MB, GB, TB): " unit
read -p "Especifique el tamaño de los archivos a generar (en $unit): " file_size

# Convertir el tamaño ingresado a bytes
file_size_bytes=$(convert_to_bytes "$unit" "$file_size")

# Contador de archivos generados
count=0

# Bucle para generar archivos hasta que el espacio en disco se agote
while true; do
    # Generar un archivo del tamaño especificado con caracteres aleatorios
    dd if=/dev/urandom of="$temp_dir/file_$count" bs="$file_size_bytes" count=1 status=none

    # Verificar si se pudo crear el archivo correctamente
    if [ $? -eq 0 ]; then
        echo "Archivo generado: $temp_dir/file_$count"
    else
        echo "Error al generar el archivo $temp_dir/file_$count"
        break
    fi

    # Incrementar el contador
    ((count++))
 
    # Verificar el espacio libre en disco
#    free_space=$(df --output=avail "$script_dir" | tail -n 1)
    
    # Si el espacio libre es menor que el tamaño del archivo, salir del bucle
    if [ "$free_space" -lt "$file_size_bytes" ]; then
        echo "Espacio en disco agotado."
        break
    fi
done

echo "Se generaron $count archivos de ${file_size}${unit} cada uno en $temp_dir."
