#! /usr/bin/fish

set dst "$HOME/development"

source /data/config/restic/restic.fish

echo "


-------------------------------------
[[ Running $script ]]
"(date -Iseconds)"
-------------------------------------
"

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

if test -z "$RESTIC_REPOSITORY"
    error "RESTIC_REPOSITORY empty. Cannot proceed"
    exit 1
end

if test -z "$RESTIC_PASSWORD_FILE"; or test -f "$RESTIC_PASSWORD_FILE"
    error "RESTIC_PASSWORD_FILE empty or does not exist. Cannot proceed"
    exit 1
end

if test -z "$AWS_ACCESS_KEY_ID"
    error "AWS_ACCESS_KEY_ID empty or does not exist. Cannot proceed"
    exit 1
end

if test -z "$AWS_SECRET_ACCESS_KEY"
    error "AWS_SECRET_ACCESS_KEY empty or does not exist. Cannot proceed"
    exit 1
end

# Create non-existing destination
echo "Creating non-existing destination" only_echo
mkdir -p "$dst"
if test $status -ne 0
    echo (set_color brred)"[ERROR] Cannot create missing destination. Exiting..." >&2
    exit 1
end

# Recover data from archive
restic restore latest \
    --host=$hostname \
    --tag=development \
    --target "$dst"
if test $status -ne 0
    echo (set_color brred)"[ERROR] Could not restore snapshot" >&2
    exit 1
end
echo "Snapshot restoration successful"
