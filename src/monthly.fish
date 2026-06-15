#! /usr/bin/fish

## Disabled
exit

cd (status dirname)
set scripts \
    "backup/restic/development.bkp.fish" \

restic unlock
for script in $scripts
    if $script
            set -a notifications "🟢 $script"
    else
        set -a notifications "🔴 $script"
    end
end
restic prune

notify "💾 sisu monthly backup report" (string join '\n' $notifications)
