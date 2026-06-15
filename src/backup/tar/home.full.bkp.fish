#! /usr/bin/fish

set src "/home/francois" # La source a sauvegarder
set dst "/l/backup/home" # La destination de la sauvegarde, doit être un dossier existant ou qui peut être créé
set full_arch "$dst/home."(date +%Y%m%dT%H%M%S | tr -d :-)".tar.zst" # Le nom de l'archive
set full_snar "$dst/home.full.snar" # Variable qui contient le chemin du fichier de snapshot 
set diff_arch "$dst/home.diff.tar.zst" # Le nom de l'archive
set diff_snar "$dst/home.diff.snar" # Variable qui contient le chemin du fichier de snapshot
set log "/var/log/automation/home.tar.bkp.log" # Le fichier de log, doit être un fichier existant ou qui peut être créé
set nb_max 1 # Le nombre maximum d'archives à conserver, les plus anciennes seront supprimées

source /home/francois/Documents/development/automation/src/tools/log.fish
or source /data/automation/tools/log.fish # inclut le fichier log.fish pour utiliser les fonctions d'écriture de log
source /home/francois/Documents/development/automation/src/tools/delete_old_backups.fish
or source /data/automation/tools/delete_old_backups.fish # inclut le fichier delete_old_backups.fish pour utiliser les fonctions génériques

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

# C'est une nouvelle sauvegarde complète, donc on supprime les anciens fichiers de snapshot
info "Suppression du fichier de snapshot"
rm -f "$full_snar" 2>&1 > /dev/null | tee -a $log
rm -f "$diff_snar" 2>&1 > /dev/null | tee -a $log
info "Suppression du lien symlink vers la sauvegarde complète précédente"
rm -f "$dst/home.full.tar.zst" 2>&1 | tee -a $log
info "Suppression de la sauvegarde différentielle"
rm -f "$diff_arch" 2>&1 | tee -a $log

# Creation de l'archive
info "Creation de l'archive $full_arch"
tar --create --verbose --zstd \
    --listed-incremental "$full_snar" \
    --exclude 'Documents/development' --exclude '.cache' --exclude '.vscode*' \
    --exclude '.var' --exclude '.mozilla' --exclude '.dotnet' --exclude 'Xmas' \
    --exclude '.copilot' --exclude '.local' --exclude 'Games' \
    --file "$full_arch" \
    --directory (dirname $src) \
    (basename $src) 2>&1 | tee -a $log
# Vérifie que la création de l'archive a réussi
if test $pipestatus[1] -ne 0
    error "La sauvegarde a échoué"
    exit 1
end
success "La sauvegarde a réussi"

# Crée un lien symbolique vers la sauvegarde complète 
info "Creation d'un lien symbolique vers la sauvegarde complète"
ln -s "$full_arch" "$dst/home.full.tar.zst" 2>&1 | tee -a $log
if test $status -ne 0
    warning "La création du lien symbolique a échoué"
end
success "La création du lien symbolique a réussi"


#Supprime les anciennes sauvegardes en gardant au maximum $nb_max sauvegardes
info "Suppression des anciennes sauvegardes"
delete_old_backups "$dst" "home.20*.tar.zst" $nb_max
if test $status -eq 0
    success "Anciennes sauvegardes supprimées avec succès"
else
    warning "Impossible de supprimer les anciennes sauvegardes"
end
