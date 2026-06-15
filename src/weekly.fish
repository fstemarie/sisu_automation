#! /usr/bin/fish

# inclut le fichier log.fish pour utiliser les fonctions d'écriture de log
source /home/francois/Documents/development/automation/src/tools/notify.fish
or source /data/automation/tools/notify.fish

# S'assure que la variable d'environnement soit effacee a la fin du script
function on_exit --on-event fish_exit
    set -Ue __WARNINGS__
end

cd (status dirname)
set scripts \
    "backup/restic/automation.bkp.fish" \
    "backup/tar/automation.bkp.fish"

restic unlock
for script in $scripts
    set -Ue __WARNINGS__
    if $script
        if set -Uq __WARNINGS__
            set -a notifications "🟢 $script"
        else
            set -a notifications "⚠️ $script"
        end
    else
        set -a notifications "🟥$script"
    end
end
restic prune

notify "💾 sisu weekly backup report" (string join '\n' $notifications)
