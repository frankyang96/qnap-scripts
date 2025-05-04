#!/bin/bash

set -e

src_crt="/share/homes/admin/.acme.sh/domain.com/domain.com.cer"
src_key="/share/homes/admin/.acme.sh/domain.com/domain.com.key"
jellyfin_path="/share/CACHEDEV1_DATA/docker_data/Jellyfin/config/ssl"
jellyfin_crt="/share/CACHEDEV1_DATA/docker_data/Jellyfin/config/ssl/domain.com.cer"
jellyfin_key="/share/CACHEDEV1_DATA/docker_data/Jellyfin/config/ssl/domain.com.key"

qnap_path="/mnt/HDA_ROOT/.config/stunnel"
qnap_crt="/mnt/HDA_ROOT/.config/stunnel/domain.com.cer"
qnap_key="/mnt/HDA_ROOT/.config/stunnel/domain.com.key"
qnap_pem="/mnt/HDA_ROOT/.config/stunnel/stunnel.pem"


function log {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> /share/homes/admin/cert_replace.log
}

function send_mail {
# Replace resend-key
    local API_KEY="${RESEND_API_KEY:-re_xxxxxxxxxxxxxxxxTa2a}"
    
    if [[ -z "$API_KEY" ]]; then
        log "Error: RESEND_API_KEY not set. Email not sent."
        return 1
    fi

    response=$(curl -s -o /tmp/mail_response.json -w "%{http_code}" -X POST 'https://api.resend.com/emails' \
        -H "Authorization: Bearer $API_KEY" \
        -H 'Content-Type: application/json' \
        --data-binary @- <<EOF
{
  "from": "cert_reminder <cert_reminder@domain.com>",
  "to": ["test1@gmail.com","test2@gmail.com""],
  "subject": "WebCert is updated, please check and replace manually if necessary!",
  "html": "<p>WebCert is updated, please check and replace manually if necessary!</p>"
}
EOF
    )

    if [[ "$response" -ne 200 ]]; then
        log "Email sending failed! HTTP Status: $response, Response: $(cat /tmp/mail_response.json)"
        return 1
    else
        log "Email sent successfully."
    fi
}



function jellyfin {

if cmp -s "$src_crt" "$jellyfin_crt"; then
    log "Jellyfin cert is up to date"
else
    log "Updating Jellyfin cert..."

    cp "$src_crt" "$jellyfin_crt"
    cp "$src_key" "$jellyfin_key"
    openssl pkcs12 -export -out "$jellyfin_path/jellyfin.pfx" -inkey "$jellyfin_key" -in "$jellyfin_crt" -passout pass:
    log "jellyfin certs replaced, pfx generated"

    docker restart jellyfin > /dev/null
    log "jellyfin docker restarted"
fi
}

function qnap_http () {
#    if [[ -f "$qnap_crt" && -f "$src_crt" ]] && cmp -s "$src_crt" "$qnap_crt"; then
#    if cmp -s "$src_crt" "$JELLyfin_crt"; then
    if cmp -s "$src_crt" "$qnap_crt"; then
        log "QNAP cert is up to date."
    else
        log "Updating QNAP cert..."
        cp "$src_crt" "$qnap_crt"
        cp "$src_key" "$qnap_key"
        
        cat "$qnap_key" "$qnap_crt" > "$qnap_pem"
        
        log "QNAP cert replaced."
        
        for service in Qthttpd thttpd stunnel; do
            /etc/init.d/"$service".sh restart > /dev/null && log "$service restarted."
        done
        log "Qnap services restarted."
#        send_mail
    fi

}



function check_cert_send_mail {

echo ""

}



function main {

    jellyfin
    qnap_http
}

main
