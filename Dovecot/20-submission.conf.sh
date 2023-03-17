#!/bin/bash
echo "
submission_relay_host = 127.0.0.1
submission_relay_port = 25

protocol submission {

}
" > /etc/dovecot/conf.d/20-submission.conf
