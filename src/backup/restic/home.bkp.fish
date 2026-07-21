#! /usr/bin/fish

set src "/home/francois" # La source a sauvegarder
set log "/var/log/automation/home.restic.bkp.log" # Le fichier de log

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

#region Verifie que les variables d'environnement nécessaires sont définies et valides
# Verifie que la variable d'environnement RESTIC_REPOSITORY est définie et n'est pas vide
info "Vérification de la variable d'environnement RESTIC_REPOSITORY"
if test -n "$RESTIC_REPOSITORY"
    success "RESTIC_REPOSITORY est definie"
else
    error "RESTIC_REPOSITORY est non defini"
    exit 1
end
# Verifie que le fichier de mot de passe existe et n'est pas vide
info "Vérification de la variable d'environnement RESTIC_PASSWORD_FILE"
if test -n "$RESTIC_PASSWORD_FILE"; and test -e "$RESTIC_PASSWORD_FILE"
    success "RESTIC_PASSWORD_FILE est definie et existe"
else
    error "RESTIC_PASSWORD_FILE vide ou n'existe pas"
    exit 1
end
info "Vérification de la variable d'environnement AWS_ACCESS_KEY_ID"
if test -n "$AWS_ACCESS_KEY_ID"
    success "AWS_ACCESS_KEY_ID est definie"
else
    error "AWS_ACCESS_KEY_ID vide ou n'existe pas. Impossible de continuer"
    exit 1
end
info "Vérification de la variable d'environnement AWS_SECRET_ACCESS_KEY"
if test -n "$AWS_SECRET_ACCESS_KEY"
    success "AWS_SECRET_ACCESS_KEY est definie"
else
    error "AWS_SECRET_ACCESS_KEY vide ou n'existe pas. Impossible de continuer"
    exit 1
end
# Verifie que le dossier source existe
info "Vérification de l'existence du dossier source"
if test -d "$src"
    success "Le dossier source existe"
else
    error "Le dossier source n'existe pas"
    exit 1
end
#endregion

# Crée un snapshot avec restic en excluant les dossiers et fichiers qui ne sont pas nécessaires
info "Creation du snapshot restic"
cd "$src"
restic backup \
    --host $hostname \
    --tag home \
    --exclude 'Documents/development' --exclude '.cache' --exclude 'cache' --exclude 'Cache' --exclude 'logs' \
    --exclude '.config/Code' --exclude '.vscode*' --exclude '.dotnet' --exclude '.copilot' \
    --exclude '.local' --exclude 'Games' --exclude '.var' --exclude '.mozilla' --exclude '.thunderbird' \
    --exclude '.config/Element' --exclude '.config/another-window-session-manager' --exclude '.config/another-window-session-manager' \
    --exclude '.config/OpenRGB' --exclude '.secrets' \
    .  2>&1 | tee -a $log
# Vérifie si la commande backup a réussi
if test $pipestatus[1] -ne 0
    error "Il y a eu une erreur lors de la création du snapshot"
    exit 1
end
success "Le snapshot a été créé avec succès"

# Supprime les snapshots plus anciens que 4 semaines en gardant au moins un snapshot par semaine
info "Effacement des snapshots"
restic forget \
    --host $hostname \
    --tag home \
    --keep-daily 7 --keep-weekly 4 --keep-monthly 6 2>&1 | tee -a $log
# Vérifie si la commande forget a réussi
if test $pipestatus[1] -ne 0
    error "La suppression des snapshots a échouée"
    exit 1
end
success "La suppression des snapshots a réussie"
