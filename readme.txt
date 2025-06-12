cd\FullStack\fullstackapi
git init
git remote add origin https://github.com/mauandrade99/fullstackapi



cd\FullStack\fullstackapi
git init
git add .
git commit -m "fullstackapi 1.00"
git branch -M main
git push -u origin main


CREATE USER admin WITH PASSWORD 'admin';
ALTER USER admin WITH SUPERUSER;
ALTER DATABASE apifullstack OWNER TO admin


http://vpsw2882.publiccloud.com.br:8080/login
