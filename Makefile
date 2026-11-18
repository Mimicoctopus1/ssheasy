all: web proxy
	# To run, you must have the "nginx" user on your system.

web: web/main.wasm

proxy: proxy/proxy

clean:
	rm -f web/main.wasm
	rm -f proxy/proxy
	rm -f connections.log
	# You may want to now use "make clean-backup" to delete the backups.

install: install-web

uninstall:
	rm -rf /usr/share/nginx/html/*
	rm -rf /etc/nginx/nginx.conf

backup:
	if [ ! -e /usr/share/nginx/html.old ] ; then cp -rf /usr/share/nginx/html /usr/share/nginx/html.old ; fi
	if [ ! -e /etc/nginx/nginx.conf.old ] ; then cp -rf /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old ; fi
	# Use "make restore-backup" to restore the backups.
	# You may also want to use "make uninstall", which deletes default files so that make will install this program's instead.

restore-backup:
	rm -rf /usr/share/nginx/html
	cp -rf /usr/share/nginx/html.old /usr/share/nginx/html
	cp -f /etc/nginx/nginx.conf.old /etc/nginx/nginx.conf
	# You may want to now use "make clean-backup" to delete the backups.

clean-backup:
	rm -rf /usr/share/nginx/html.old
	rm -f /etc/nginx/nginx.conf.old

install-web: install-web-wasm install-web-static

install-web-wasm: /usr/share/nginx/html/wasm_exec.js /usr/share/nginx/html/main.wasm

install-web-static: /usr/share/nginx/html/browser.html /usr/share/nginx/html/index.html /usr/share/nginx/html/node_modules /usr/share/nginx/html/sw.js /usr/share/nginx/html/webauthn.html /etc/nginx/nginx.conf

/usr/share/nginx/html/wasm_exec.js:
	install -C /usr/local/go/lib/wasm/wasm_exec.js /usr/share/nginx/html

/usr/share/nginx/html/browser.html:
	install -C web/html/browser.html /usr/share/nginx/html

/usr/share/nginx/html/index.html:
	install -C web/html/index.html /usr/share/nginx/html

/usr/share/nginx/html/node_modules:
	cp -r web/html/node_modules /usr/share/nginx/html

/usr/share/nginx/html/sw.js:
	install -C web/html/sw.js /usr/share/nginx/html

/usr/share/nginx/html/webauthn.html:
	install -C web/html/webauthn.html /usr/share/nginx/html

/etc/nginx/nginx.conf:
	install -C nginx/nginx.conf /etc/nginx

/usr/share/nginx/html/main.wasm:
	install -C web/main.wasm /usr/share/nginx/html

web/main.wasm:
	cd web ; GOOS=js GOARCH=wasm go build -o main.wasm

proxy/proxy:
	cd proxy ; go build .
