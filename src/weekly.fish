#! /usr/bin/fish

cd (status dirname)
set scripts \
    "backup/restic/automation.bkp.fish" \
    "backup/tar/automation.bkp.fish"

restic unlock
for script in $scripts
    if $script
            set -a notifications "🟢 $script"
    else
        set -a notifications "🔴 $script"
    end
end
restic prune

notify "💾 sisu weekly backup report" (string join '\n' $notifications)
