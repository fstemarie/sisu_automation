#! /usr/bin/fish

set src "$HOME"
set dst "/l/backup/$hostname/home"
set arch "$dst/home."(date +%Y%m%dT%H%M%S | tr -d :-)".tar.zst"
set log "/var/log/automation/home.tar.log"
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
info "Source folder: $src"

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
        error "Cannot create missing destination. Exiting..."
        exit 1
    end
end
info "Destination folder: $dst"

info "Creating archive $arch"
pushd "$src" || { echo "pushd failed - $src"; exit 1; }
printf '%s\n' \
    Desktop \
    Documents \
    Downloads \
    Music \
    Templates \
    Pictures \
    Videos \
    .config \
    .gnupg \
    .password-store \
    .pki \
    .secrets \
    .ssh \
    .vim \
    .face \
    .gitconfig \
    .profile \
    .viminfo \
    .vimrc |
tar --create --verbose --zstd \
    --file="$arch" \
    --directory="$src" \
    --exclude={"Documents/development", ".config/Element", ".config/Code"} \
    --files-from=- 2>&1 | tee -a $log 
if test $status -ne 0
    error "Backup unsuccessful"
    exit 1
end
popd
log "The backup was successful"

alias backups="command ls -1trd $dst/home.*.tar.zst"
set nb_tot (backups | count)
set nb_diff (math $nb_tot - $nb_max)
if test $nb_diff -gt 0
    info "Removing older archives"
    backups | head -n$nb_diff | tee -a $log
    backups | head -n$nb_diff | xargs rm -f > /dev/null
end
