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

Criei o arquivo assets/config.inc.php-dist para podermos capturar (getenv) as configurações do banco de dados (nome, usuário, host [padrão "db"], e a senha) não necessitando de termos que fazer manualmente, abrindo e editando mais um arquivo. A senha, também, devem ser alterada nos arquivos Dockerfile e docker-compose.yml.


Instruções (use o terminal para digitar os comandos a seguir)
--------------------------------------------------------
Crie uma pasta para o projeto (ex: /home/user/projetos/)

Clone este repositório (vai criar uma subpasta ocomon_5)

git clone https://github.com/adrianoleal/ocomon_5.git

Adentre a pasta ocomon_5 e construa a imagem, execute o compose:

docker-compose up -d --build

Aguarde o tempo necessário para baixar o ocomon, descompactar, aplicar as configurações e permissões e etc (demora um tanto).

Obs: Altere a senha padrão do mysql (banco de dados) nos arquivos docker-compose e .env.
O timezone está definido para America/Porto_Velho, pode ser alterado no arquivo config.inc.php-dist antes da criação da imagem.

Acesso ao OcoMon
http://localhost:8081
Usuário: admin Senha: admin

Site do OcoMon: https://ocomon.com.br/site/
