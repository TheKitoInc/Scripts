#!/bin/bash

touch /etc/postfix/virtual_alias_maps
postmap /etc/postfix/virtual_alias_maps

postconf 'virtual_alias_maps = hash:/etc/postfix/virtual_alias_maps'
postconf 'virtual_alias_domains = $virtual_alias_maps'

/etc/init.d/postfix reload
