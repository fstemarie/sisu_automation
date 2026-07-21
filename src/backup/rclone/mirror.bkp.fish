#! /usr/bin/fish

set src "/l/backup/" # Variable qui contient le chemin du dossier à sauvegarder
set dst "filelu-s5:/backup.bkt/sisu" # Variable qui contient le chemin du dossier de destination où les sauvegardes seront stockées
set log "/var/log/automation/mirror.rclone.bkp.log" # Variable qui contient le chemin du fichier de log où les messages d'information et d'erreur seront enregistrés
# set secret_file "/home/francois/.secrets/filelu" # Variable qui contient le chemin du fichier qui contient le mot de passe de filelu

# inclut le fichier log.fish pour utiliser les fonctions d'écriture de log
source /home/francois/Documents/development/automation/src/tools/log.fish
or source /data/automation/tools/log.fish

# Ecrit l'entete du log pour cette execution du script
echo "

-------------------------------------
[[ Execution de "(status basename)" ]]
"(date -Iseconds)" 
-------------------------------------
" | tee -a $log

info "Sauvegarde du dossier $src vers $dst"

# Vérifie que la source existe et vérifie que la destination existe
# Si le dossier source n'existe pas, alors il n'y a rien à sauvegarder
info "Vérification de l'existence du dossier source"
if test -d "$src"
    success "Le dossier source existe"
else
    error "Le dossier source n'existe pas"
    exit 1
end

# Transfer rclone
info "Synchronise les sauvegardes sur le cloud avec rclone"
rclone sync \
    --transfers 5 --checkers 5 \
    --verbose --fast-list \
    --check-first --ignore-existing \
    --exclude "*.full.tar.zst" \
    "$src" "$dst" &| tee -a $log
# Vérifie si la commande rclone a réussi
if test $pipestatus[1] -ne 0
    error "La sauvegarde a échoué"
    exit 1
end
success "La sauvegarde a réussi"
