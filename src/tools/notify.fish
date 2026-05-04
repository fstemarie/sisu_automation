
function notify \
    -d "Send a notification through ntfy.sh" \
    -a title message

    set topic falarie-francois-automation

    echo -ne $message | curl -T- \
        -H "title: $title" \
        -H "priority: low" \
        https://ntfy.sh/$topic
end
