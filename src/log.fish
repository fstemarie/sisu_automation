#! /usr/bin/fish

function log --description 'Log the info to a file and the logger' -a message
    # Create the log file if it doesn't exist
    if test ! -e $log
        touch $log_file
    end

    echo "[INFO] $message" | tee -a $log
    echo "[INFO] $message" >> $log
    logger -t $script "$message"
end

function info --description 'Log the info to a file and to the screen' -a message
    # Create the log file if it doesn't exist
    if test ! -e $log
        touch $log_file
    end

    echo "[INFO] $message"
    echo "[INFO] $message" >> $log
end

function warning --description 'Log the warning to a file and the logger' -a message
    # Create the log file if it doesn't exist
    if test ! -e $log
        touch $log_file
    end

    echo (set_color bryellow)"[WARNING] $message"
    echo "[WARNING] $message" >> $log
end

function error --description 'Log the error to a file and the logger' -a message
    # Create the log file if it doesn't exist
    if test ! -e $log
        touch $log_file
    end

    echo (set_color brred)"[ERROR] $message"
    echo "[ERROR] $message" >> $log
    logger -t $script "[ERROR] $message"
end
