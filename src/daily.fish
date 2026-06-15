#! /usr/bin/fish

cd (status dirname)
set scripts \
    "backup/restic/development.bkp.fish" \
    "backup/restic/home.bkp.fish" \
    "backup/tar/development.bkp.fish" \
    "backup/tar/home.bkp.fish"

restic unlock
for script in $scripts
    if $script
            set -a notifications "🟢 $script"
    else
        set -a notifications "🔴 $script"
    end
end
restic prune

notify "💾 sisu daily backup report" (string join '\n' $notifications)
