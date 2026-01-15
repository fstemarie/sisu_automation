#! /usr/bin/fish

set src "/l/backup/$hostname/automation"
set dst "/data/automation"
set arch (command ls -1dr $src/automation.*.tar.zst | head -n1)
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

# Append date to name to avoid data loss
if test -d "$dst"
    echo "Destination already exists"

    set old "$dst"
    set dst "$old."(date +%s)
    while test -d "$dst"
        sleep 2
        set dst "$old."(date +%s)
    end
end

# Create non-existing destination
echo "Creating non-existing destination"
mkdir -p "$dst"
if test $status -ne 0
    echo (set_color brred)"[ERROR] Cannot create missing destination. Exiting..." >&2
    exit 1
end

# Recover data from archive
echo "Recovering..."
tar --extract --verbose --zstd \
    --file="$arch" \
    --directory="$dst" \
    --strip=1 2>&1 | tee -a $log
if test $status -ne 0
    echo (set_color brred)"[ERROR] Recovery unsuccessful" >&2
    exit 1
end
echo "The recovery was successful"
