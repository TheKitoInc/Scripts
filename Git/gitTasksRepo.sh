#!/bin/bash
        /opt/kito/scripts/gitPull.sh "$1"

        downloadApache () {
                SRC=/var/www/$(basename "$1")/
                if ssh root@$2 "[ -d $SRC ]" ; then
                        rsync -arvu --exclude=.git root@$2:$SRC "$1/"
                        /opt/kito/scripts/gitCommit.sh "$1" "Apache $2"
                fi
        }

        uploadApache () {
                DST=/var/www/$(basename "$1")/
                if ssh root@$2 "[ -d $DST ]" ; then
                        rsync --chown=www-data:www-data -arvu --exclude=.git "$1/" root@$2:$DST
                fi
        }


        cd "$1" ||  exit 1
        echo Repo: $1


        (cat .gitignore | grep "^log$"  > /dev/null) || echo log >> .gitignore
        /opt/kito/scripts/gitCommit.sh "$1" "exclude logs"

        (cat .gitignore | grep "^tmp$"  > /dev/null) || echo tmp >> .gitignore
        /opt/kito/scripts/gitCommit.sh "$1" "exclude temps"

        (cat .gitignore | grep "^.php-cs-fixer.cache$"  > /dev/null) || ([ -f .php-cs-fixer.cache ] && rm .php-cs-fixer.cache)
        /opt/kito/scripts/gitCommit.sh "$1" "php-cs-cache-remove"

        (cat .gitignore | grep "^.php-cs-fixer.cache$"  > /dev/null) || echo .php-cs-fixer.cache >> .gitignore
        /opt/kito/scripts/gitCommit.sh "$1" "php-cs-cache-ignore"

        find "$1" -depth -type f -name "*.php" -exec /home/git/scripts/php-cs-fixer.phar fix "{}" \;
#        find "$1" -depth -type d -exec /home/git/scripts/php-cs-fixer.phar fix "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "php-cs-fixer"

        find "$1" -depth -type d -name "node_modules" -ls -exec rm -r "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "node-modules-remove"

        (cat .gitignore | grep "^node_modules$"  > /dev/null) || echo node_modules >> .gitignore
        /opt/kito/scripts/gitCommit.sh "$1" "node-modules-ignore"

        find "$1" -depth -type f -name "*.js" -exec npx standard --fix  "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "js-standard-js"

        find "$1" -depth -type f -name "*.jsx" -exec npx standard --fix  "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "js-standard-jsx"

        find "$1" -depth -type f -name "*.htm" -exec prettier --config /home/git/config/prettier.config.json --write "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "prettier-htm"

        find "$1" -depth -type f -name "*.html" -exec prettier --config /home/git/config/prettier.config.json --write "{}" \;
        /opt/kito/scripts/gitCommit.sh "$1" "prettier-html"

        (cat .gitignore | grep "^/log$" > /dev/null || (echo "/log" >> .gitignore && git rm -r --cached log)) && \
        /opt/kito/scripts/gitCommit.sh "$1" "ignore-log"
