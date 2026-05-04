function delete_old_backups -a pattern nb_max \
    --description 'Supprime les anciennes sauvegardes en gardant au maximum $nb_max sauvegardes'
    set -a files (eval "command ls -trd $pattern") # Récupère la liste des fichiers correspondant au pattern, triés par date de modification (du plus ancien au plus récent)
    set nb_diff (math (count $files) - $nb_max)
    if test $nb_diff -gt 0
        set files $files[1..$nb_diff]
        command rm -vf $files | tee -a $log
        return $pipestatus[1]
    else
        return 0 # Pas de fichiers à supprimer, tout va bien
    end
end
