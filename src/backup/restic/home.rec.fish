#! /usr/bin/fish

# Append date to destination name to avoid data loss
set dst "$HOME/home."(date +%s)

echo "

-------------------------------------
[[ Running $script ]]
"(date -Iseconds)"
-------------------------------------
"

if test -z "$RESTIC_REPOSITORY"
    echo (set_color brred)"[ERROR] RESTIC_REPOSITORY empty. Cannot proceed" >&2
    exit 1
end

if test -z "$RESTIC_PASSWORD_FILE" || ! test -e "$RESTIC_PASSWORD_FILE" 
    echo (set_color brred)"[ERROR] RESTIC_PASSWORD_FILE empty or does not exist. Cannot proceed" >&2
    exit 1
end

# if target destination does not exist, create it
if test ! -d "$dst"
    echo "Creating non-existing destination"
    mkdir -p "$dst"
    if test $status -ne 0
        echo (set_color brred)"[ERROR] Cannot create missing destination. Exiting..." >&2
        exit 1
    end
end

# Recover data from archive
restic restore latest \
    --host=$hostname \
    --tag=home \
    --target "$dst"
if test $status -ne 0
    echo (set_color brred)"[ERROR] Could not restore snapshot" >&2
    exit 1
end
echo "Snapshot restoration successful"
