location /phpmyadmin {
	root /usr/share/;
	index index.php index.html index.htm;
	location ~ ^/phpmyadmin/(.+\.php)$ {
		include /etc/nginx/fastcgi_params;
		try_files $uri =404;
		fastcgi_pass unix:/var/run/php5-fpm/phpmyadmin.sock;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	}
	location ~* ^.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)$ {
		access_log off;
		log_not_found off;
		expires max;
	}
}

location /phpMyAdmin {
	rewrite ^/* /phpmyadmin last;
}