#! /usr/bin/fish

set src "/data/config" # Variable qui contient le chemin vers le dossier à sauvegarder
set dst "/l/backup/config" # Variable qui contient le chemin vers le dossier de destination de la sauvegarde
set arch "$dst/config."(date +%Y%m%dT%H%M%S | tr -d :-)".tar.zst" # Variable qui contient le chemin vers l'archive de destination, avec un nom basé sur la date et l'heure
set log "/var/log/automation/config.tar.bkp.log" # Variable qui contient le chemin vers le fichier de log
set nb_max 1 # Variable qui contient le nombre maximum d'archives à conserver

source /home/francois/development/automation/src/tools/log.fish
or source /data/automation/tools/log.fish # inclut le fichier log.fish pour utiliser les fonctions d'écriture de log
source /home/francois/development/automation/src/tools/delete_old_backups.fish
or source /data/automation/tools/delete_old_backups.fish

# Ecrit l'entete du log pour cette execution du script
echo "

-------------------------------------
[[ Execution de "(status basename)" ]]
"(date -Iseconds)"
-------------------------------------
" | tee -a $log

#region Vérifie que la source existe et vérifie que la destination existe
# Si le dossier source n'existe pas, alors il n'y a rien à sauvegarder
info "Vérification de l'existence du dossier source et du dossier de destination"
if test -d "$src"
    success "Le dossier source existe"
else
    error "Le dossier source n'existe pas. Impossible de continuer"
    exit 1
end

# Si le dossier de destination n'existe pas, le créer
if test -d "$dst"
    success "Le dossier de destination existe"
else
    info "Création du dossier de destination manquant"
    mkdir -p "$dst"
    if test $status -eq 0
        success "Dossier de destination créé avec succès"
    else
        error "Ne peut pas créer le dossier de destination manquant."
        exit 1
    end
end
#endregion

# Creation de l'archive
info "Creation de l'archive $arch"
tar --create --verbose --zstd \
    --file "$arch" \
    --directory (dirname $src) \
    (basename $src)  2>&1 | tee -a $log
# Vérifie si la commande tar a réussi
if test $pipestatus[1] -ne 0
    error "La sauvegarde a échoué"
    exit 1
end
success "La sauvegarde a réussi"

#Supprime les anciennes sauvegardes en gardant au maximum $nb_max sauvegardes
info "Suppression des anciennes sauvegardes"
delete_old_backups "$dst/config.*.tar.zst" $nb_max
if test $status -eq 0
    success "Anciennes sauvegardes supprimées avec succès"
else
    warning "Impossible de supprimer les anciennes sauvegardes"
end
