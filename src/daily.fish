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

set notifications (string join '\n' $notifications)
echo -e $notifications | curl -T- \
    -H "title: 💾 sisu daily backup report" \
    -H "priority: low" \
    -H "markdown: yes" \
    https://ntfy.sh/automation_ewNXGlvorS6g8NUr
