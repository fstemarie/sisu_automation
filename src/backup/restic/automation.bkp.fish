#! /usr/bin/fish

set src "/data/automation"
set log "/var/log/automation/automation.restic.log"
set script (status basename)

source (status dirname)/../../log.fish

echo "

-------------------------------------
[[ Running $script ]]
"(date -Iseconds)"
-------------------------------------
" | tee -a $log

if test -z "$RESTIC_REPOSITORY"
    error "RESTIC_REPOSITORY empty. Cannot proceed"
    exit 1
end

if test -z "$RESTIC_PASSWORD_COMMAND"
    error "RESTIC_PASSWORD_COMMAND empty or does not exist. Cannot proceed"
    exit 1
end

# if the source folder doesn't exist, then there is nothing to backup
if test ! -d "$src"
    error "Source folder does not exist. Cannot proceed"
    exit 1
end
info "Source folder: $src"

info "Creating restic snapshot"
pushd "$src"
restic backup \
    --host=$hostname \
    --tag=automation \
    --no-scan \
    .  2>&1 | tee -a $log
if test $status -ne 0
    error "There was an error during the snapshot"
    exit 1
end
popd
log "Snapshot created successfully"

info "Forgetting snapshots"
restic forget \
    --host=$hostname \
    --tag=automation \
    --keep-last 1  2>&1 | tee -a $log
if test $status -ne 0
    error "Unable to forget snapshots"
    exit 1
end
info "Snapshots forgotten successfully"
