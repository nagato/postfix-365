# postfix-oauth2 for Microsoft 365 
Another Postfix relay docker container with OAUTH2, but working with Microsoft 365

### USE IT AT YOUR OWN RISK

Adapted from https://github.com/takeyamajp/docker-postfix <br />
tarickb/sasl-xoauth2 installed into image https://github.com/tarickb/sasl-xoauth2 <br />

## Usage (work in progres) <br />
- clone the project (git clone https://github.com/mauroreggio/postfix-365.git) <br />
- edit docker-compose.yml with right parameters <br />
- run "docker-compose up" for interactive log on console or <br />
- run "docker-compose up -d" for run like a daemon in background (docker ps -a for check the status) <br />

Based on Alma Linux 9.5, the active docker do:
- Read all ENV variables in docker-compose.yml <br />
- Copy ./scripts folder into the container <br />
- Use ./scripts/entrypoint.sh as a startup script (that run all other scripts)

After run the container, remember last step: create Initial Access Token <br />
https://github.com/tarickb/sasl-xoauth2#initial-access-token-2 <br />
This step consist in: <br />
- bash into the running container
- run the script that assist you
- this create an example@example.com file in /etc/tokens folder of the container, mapped on the ./tokens local folder. <br />
NOT TESTED: the "sasl-xoauth2-tool" is a perl script. If you desire you can install and run out of the container and create the example@example.com file in the ./tokens local folder. Don't forget to assign postfix:postfix own group:user to the file from the container bash (only first time you run, is persistent) <br />

## Debug <br />
### bash into running container
docker exec -it postfix bash <br />

### within the running container
/usr/sbin/postfix -c /etc/postfix start <br />
/usr/sbin/postfix -c /etc/postfix stop <br />

## Modify and create a new docker image <br />
"docker build -t localhost/postfix-365:tag ." <br />
(or if you want build without any docker cache: "docker build --no-cache -t localhost/postfix-365:1.0.0 .") <br />

<br />
<br />




