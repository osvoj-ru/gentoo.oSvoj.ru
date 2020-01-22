# gentoo.oSvoj.ru
репозитарий для gentoo от оСвой.рф
для подключения создайте файл:
### /etc/portage/repos.conf/gentoo.osvoj.ru.conf
```
[gentoo-osvoj-ru]
location = /var/git/repos/gentoo.osvoj.ru
sync-type = git
sync-uri = https://github.com/osvoj-ru/gentoo.oSvoj.ru.git
auto-sync = true
priority = 9
```
