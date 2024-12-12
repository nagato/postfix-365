# postfix-oauth2 for Microsoft 365 
Another Postfix relay docker container with OAUTH2, but working with Microsoft 365

Adapted from https://github.com/takeyamajp/docker-postfix

## Usage (work in progres) <br />
- pull the project (git pull https://github.com/mauroreggio/postfix-oauth2.git) <br />
- edit docker-compose.yml with right parameters <br />
- run "docker-compose up" for interactive log on console or <br />
- run "docker-compose up -d" for run like a daemon in background (docker ps -a for check the status) <br />

Based on Alma Linux 9.5, the active docker do:
- Read all ENV variables in docker-compose.yml <br />
- Copy ./scripts folder into the container <br />
- Use ./scripts/entrypoint.sh as a startup script (that run all other scripts)

## Debug <br />
### bash into running container
docker exec -it postfix bash <br />

### within the running container
/usr/sbin/postfix -c /etc/postfix start
/usr/sbin/postfix -c /etc/postfix stop

## Modify and create a new docker image <br />
"docker build -t postfix:tag ." <br />
(or if you want build without any docker cache: "docker build --no-cache -t postfix:1.0.0 .") <br />

<br />
<br />




