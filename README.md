Documentação do projeto Dockerized da Ocomon 5
Teste da versão Ocomon_5, imagens (web, db e cron) separadas.
--------------------------------------------------------------
Índice
Introdução
Pré-requisitos
Configuração do projeto
Configuração do ambiente
Construindo e executando o projeto
Acessando o aplicativo
Configuração do Cron Job
Gerenciamento de Logs
Solução de problemas
________________________________________________________________
1. Introdução
--------------
Este documento fornece instruções sobre como configurar e executar o projeto Ocomon em um ambiente Dockerizado. Ele inclui etapas para configuração, construção de imagens Docker, execução de contêineres e gerenciamento de logs.

2. Pré-requisitos
-----------------
Antes de começar, certifique-se de ter o seguinte instalado no seu sistema:

Docker
Docker Compose

3. Configuração do projeto
---------------------------
Clone o repositório do projeto:

git clone https://github.com/adrianoleal/ocomon_5.git
cd ocomon_5

4. Configuração do ambiente
---------------------------
Crie/Edite um arquivo .env no diretório raiz do projeto com o seguinte conteúdo (altere que o quiser/souber o que está fazendo):
*Altere a senha do Mysql, Time_Zone e Tz_Cron para suas necessidades!!!

DB_HOST=db
DB_NAME=ocomon_5
DB_USER=ocomon_5
DB_PASSWORD=senha_ocomon_mysql
MYSQL_ROOT_PASSWORD=your_root_password
TIME_ZONE=America/Porto_Velho
OCOMON_LINK="https://sourceforge.net/projects/ocomonphp/files/OcoMon_5.0/Final/ocomon-5.0.tar.gz/download"
FOLDER_NAME="ocomon-5.0"
DB_INSTALL=01-DB_OCOMON_5.x-FRESH_INSTALL_STRUCTURE_AND_BASIC_DATA.sql
TZ_CRON=AMT

5. Construindo e executando o projeto
-------------------------------------
Crie as imagens do Docker:
docker-compose build

Inicie os containers:
docker-compose up -d

6. Acessando o Ocomon 5:
-------------------------
Abra seu navegador e digite o endereço aonde se hospeda seu servidor, seguido da porta (neste projeto 8081) http://localhost:8081 para acessar o Ocomon.

7. Solução de problemas
Se você encontrar algum problema, verifique os logs do container:
docker-compose logs

Para problemas de tarefa cron, verifique os logs do container cron:
docker logs ocomon_cron

Certifique-se de que todas as variáveis ​​de ambiente estejam definidas corretamente no arquivo .env e, caso fizer alguma alteração/acréscimo, referenciar no Dockerfile e docker-compose.yml.

Esta documentação fornece um guia claro e conciso para configurar e executar o projeto Ocomon 5 em um ambiente Dockerizado. Siga cada etapa cuidadosamente e consulte a seção de solução de problemas se encontrar algum problema.
_________________________________________________





Arquivo Dockerfile para montar uma imagem Docker com o OcoMon 5.0.

As imagens são montada sobre php:8.3-apache, mysql:5.7 e alpine:3.18

Apache
PHP 8.3
Mysql
Todas as configurações de ambiente para o funcionamento adequado do OcoMon.
O download do OcoMon 5.0 é realizado durante o build da imagem.

Arquivo Dockerfile, além de construir imagem do PHP, Mysql e Crontab, restaura o db inicial.



Aguarde o tempo necessário para baixar o ocomon, descompactar, aplicar as configurações e permissões e etc (demora um tanto).

Obs: Altere a senha padrão do mysql (banco de dados) nos arquivos docker-compose e .env.
O timezone está definido para America/Porto_Velho, pode ser alterado no arquivo config.inc.php-dist antes da criação da imagem.

Acesso ao OcoMon
http://localhost:8081
Usuário: admin Senha: admin

Site do OcoMon: https://ocomon.com.br/site/
