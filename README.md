# ocomon_5
Teste da versão Ocomon_5, imagens (web, db e cron) separadas.
--------------------------------------------------------

Arquivo Dockerfile para montar uma imagem Docker com o OcoMon 5.0.

As imagens são montada sobre php:8.3-apache, mysql:5.7 e alpine:3.18

Apache
PHP 8.3
Mysql
Todas as configurações de ambiente para o funcionamento adequado do OcoMon.
O download do OcoMon 5.0 é realizado durante o build da imagem.

Arquivo Dockerfile, além de construir imagem do PHP, Mysql e Crontab, restaura o db inicial.


Requisitos
--------------------------------------------------------
É necessário que você tenha o Docker e docker-compose instalado em seu ambiente.

Criei o arquivo assets/config.inc.php-dist para podermos configurar o endereço do banco de dados (neste caso "db") e a senha. A senha, também, devem ser alterada nos arquivos Dockerfile e docker-compose.yml.
Quando eu mapeio a pasta /var/www/html, em qualquer linha do arquivo docker-compose.yml, substitui todo o conteúdo. Por esse motivo eu criei o arquivo assets/config.inc.php-dist.


Instruções (use o terminal para digitar os comandos a seguir)
--------------------------------------------------------
Crie uma pasta para o projeto (ex: /home/user/projetos/)

Clone este repositório

git clone https://github.com/adrianoleal/ocomon_5.git

Na pasta ocomon_5, execute o compose:

docker-compose up --build

Acesso ao OcoMon
http://localhost:8081
Usuário: admin Senha: admin

Site do OcoMon: https://ocomon.com.br/site/
