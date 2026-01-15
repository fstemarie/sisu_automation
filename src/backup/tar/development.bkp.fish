#! /usr/bin/fish

set src "$HOME/Documents/development"
set dst "/l/backup/$hostname/development"
set arch "$dst/development."(date +%Y%m%dT%H%M%S | tr -d :-)".tar.zst"
set log "/var/log/automation/development.tar.log"
set nb_max 5
set dir (dirname "$src")
set base (basename "$src")
set script (status basename)

source (status dirname)/../../log.fish

echo "

-------------------------------------
[[ Running $script ]]
"(date -Iseconds)"
-------------------------------------
" | tee -a $log

# if the source folder doesn't exist, then there is nothing to backup
if test ! -d "$src"
    error "Source folder does not exist"
    exit 1
end

# Check to see if the share is mounted
if test ! -d (dirname "$dst")
    error "Backup share not mounted. Exiting..."
    exit 1
end

# if the destination folder does not exist, create it
if test ! -d "$dst"
    log "Creating non-existing destination"
    mkdir -p "$dst"
    if test $status -ne 0
        logger -t $script "Cannot create missing destination. Exiting..."
        echo "$script -- Cannot create missing destination. Exiting..."
        exit 1
    end
end

info "Creating archive $arch"
tar --create --verbose --gzip \
    --exclude={'.venv', 'node_modules', '.git', '__pycache__'} \
    --file="$arch" \
    --directory="$dir" "$base"  2>&1 | tee -a $log
if test $status -ne 0
    error "Backup unsuccessful"
    exit 1
end
info "The backup was successful"

alias backups="command ls -1trd $dst/development.*.tar.zst"
set nb_tot (backups | count)
set nb_diff (math $nb_tot - $nb_max)
if test $nb_diff -gt 0
    info "Removing older archives"
    backups | head -n$nb_diff | tee -a $log
    backups | head -n$nb_diff | xargs rm -f > /dev/null
end
