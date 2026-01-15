#! /usr/bin/fish

set src "/l/backup/$hostname/home"
# Append date to destination name to avoid data loss
set dst "$HOME/home."(date +%s)
set arch (command ls -1dr $src/home.*.tar.zst | head -n1)
set script (status basename)

echo "

-------------------------------------
[[ Running $script ]]
"(date -Iseconds)"
-------------------------------------
"

# if archive does not exist, exit
if test ! -f "$arch"
    echo (set_color brred)"[ERROR] Archive not found" >&2
    exit 1
end
echo "Using archive: $arch"

# if target destination does not exist, create it
if test ! -d "$dst"
    echo "Creating non-existing destination: $dst"
    mkdir -p "$dst"
    if test $status -ne 0
        echo (set_color brred)"[ERROR] Cannot create missing destination. Exiting..." >&2
        exit 1
    end
end

# Recover data from archive
echo "Recovering..."
tar --extract --verbose --zstd \
    --file="$arch" \
    --directory="$dst" \
    --strip=1 2>&1 | tee -a $log
    --strip=1 
if test $status -ne 0
    echo (set_color brred)"[ERROR] Recovery unsuccessful" >&2
    exit 1
end
echo "The recovery was successful"
