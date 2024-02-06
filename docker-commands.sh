

# Executa container, se não existir a imagem UBUNTU no ambiente local faz download de DockerHub e depois inicia container
# O Docker Hub é um grande repositório de imagens que podemos utilizar
docker run ubuntu  # padrão bash (tempo de execução do terminal)
docker run ubuntu slepp 1d # manter o container por 1 dia

# Exibe containers em execução
docker ps
docker container ls

# Exibe detalhes de execução de containers
docker ps -a

# Exibe detalhes de execução de containers com tamanho (size)
docker ps -s

# Inicia container
docker start $idContainer

# Para container
docker stop $idContainer
docker stop -t=0 $idContainer # para o container imadiatamente

# Executar comandos Linux dentro do container
docker exec -it $idContainer bash

# Pausar container
docker pause $idContainer

# "Despausar" container
docker unpause $idContainer

# Remover container
docker rm $idContainer

# Parar e Remover container
docker rm $idContainer --force

# Executar um container acessível via navegador usando uma imagem presente no DockerHub
# -d : não trava terminal
docker run -d dockersamples/static-site

# Executa container e expoem portas (número da porta automatico)
 docker run -d -P dockersamples/static-site
 
# Executa container e define porta expecifica para expor no localhost
#       portaExterna : portaContainer
docker run -d -p 8080:80 dockersamples/static-site

# Exibe portas do container
docker port $idContainer

# Lista imagens disponíveis no ambiente local
docker images

# Faz download de imagens do DockerHub
docker pull $nomeImagem

# Detalhes e informações da imagem
docker inspect $idImagem

# Camadas que formam a imagem, 
# e ao realizar um docker pull, pode ocorrer do download 
# a ser realizado seja apenas das camadas que você não possui
# no ambiente local
docker history $idImagem

# cria minha imagem de docker para ser usada para criação do container
docker build -t giovannibiffi/app-node:1.0 .

# em caso de usar WSL no Windows, deve copiar a pasta da aplicação Node.js com Dockerfile sem extensão
# para pasta raiz do usuário ou a pasta onde quer fazer o buld da imagem.

# criar container a partir da minha imagem Node.js
# comando deve ser rodado dentro da pasta onde esta o dockerfile e vai manter
# a mesma pasta como referencia para instalação e exeução da aplicação. 
docker run -d -p 8080:3000 giovannibiffi/app-node:1.0 .

# No Linux o arquivo Dockerfile, de criação da imagem 
# não deve ter extensão para execução correta do comando anterior

# Parar todos os containers em execução
docker stop $(docker container ls -q)

# Remove todos os containers, inclusive os parados, forçando a remoção
docker rm $(docker container ls -aq) --force

# FROM node:14           --> imagem base para minha imagem
# WORKDIR /app-node      --> pasta onde será criada a imagem
# ARG PORT_BUILD=6000    --> porta de build da imagem
# ENV PORT=$PORT_BUILD   --> variável de ambiente dentro do container 
# EXPOSE $PORT_BUILD     --> porta ondem a aplicação será exposta no container
# COPY . .				 --> copia do diretorio base da aplicação para o diretorio da imagem
# RUN npm install        --> instalação do Node.js ou qualquer outra ferramenta necessária para rodar a aplicação
# ENTRYPOINT npm start   --> inicialização do servidor Node.js ou qualquer outra inicialização necessária

# para fazer o login no DockerHub antes de fazer envio de alguma imagem
docker login -u giovannibiffi

# para fazer o upload de alguma imagem para o DockerHub
# primeiro o nome do usuário do DockerHub deve estar no iniciao do nome da imagem, barra nome dois pontos versão.
# docker push nomeUsuarioDockerHub/aplicativo:numeroVersao
docker push giovannibiffi/app-node:1.0

# ao fazer o upload de versões, o DockerHub vai identificar camadas pré existentes
# e vai suber somente aquelas que foram modificadas
docker push giovannibiffi/app-node:1.1 

# Para renomear a imagem e manter o mesmo ID
docker tag nomedaimagem/app-node:1.0 giovannibiffi/app-node:1.0

# Remover todas as imagens, forçando a remoção
docker rmi $(docker image ls -aq) --force

# Executar um docker do ubuntu em modo interativo usando o bash (só ficará disponível durante a execução do bash)
docker run -it ubuntu bash

# cria pasta no Linux, pasta para amarzenar o volume do container no caso de armazenamento de dados
mkdir volume-docker

# criar um volume para armazenar dados do docker na maquina local (neste caso executando bash)
# todos os arquivos criados no docker que estão na pasta app do docker, também existirão na pasta volume-docker
# Volume : Com volumes, é possível escrever os dados em uma camada persistente.
docker run -it -v /home/giovanni/volume-docker:/app ubuntu bash

# cria volume também, mas usando outro parametro mais recomendado --mount
# Bind mounts :  Com bind mounts, é possível escrever os dados em uma camada persistente baseado na estrutura de pastas do host.
docker run -it --mount type=bind,source=/home/giovanni/volume-docker,target=/app ubuntu bash

# listar volumes
docker volume ls

# criar volume 
docker volume create giovanni-volume

# usar volume para criação do Docker
docker run -it -v giovanni-volume:/app ubuntu bash
docker run -it --mount source=giovanni-volume,target=/app ubuntu bash

# o volume estará na pasta  - a persistência de dados independe de como as pastas do sistema estão estruturadas.
cd /var/lib/docker/giovanni-volume/_data/


# criando a persistencia de volume com TMPFS, que armazena somente na memoria do container
# se o container for removido, a informacao sera removida
# usado somente no caso da informacao nao poder ser gravada na camada de ReadAndWrite
docker run -it --tmpfs=/app ubuntu bash
docker run -it --mount type=tmpfs,destination=/app ubuntu bash

# informacoes do container, inclusive pontes de rede
docker inspect $idContainer

# lista as redes gerenciadas pelo docker
docker network ls

# Cria ponte personalizada para comunicação entre containers
docker network create --driver bridge giovanni-bridge

# criar containers e adicionar na rede criada
docker run -it --name ubuntu1 --network giovanni-bridge ubuntu bash
docker run -it --name pong --network giovanni-bridge ubuntu bash

# atualizar cada container comando Linux
apt-get update

# instalar ferramenta de ping (teste de comunicação de rede)
apt-get install iputils-ping -y

# testar do container ubuntu1 o comando 
ping pong 

# cria um container sem comunicação ponte
docker run -d --network none ubuntu sleep 1d

# cria um container usando as configurações do host, maquina local
# remove o isolamento da camada de rede.
docker run -d --network host giovannibiffi/app-node:1.0

# A rede host remove o isolamento entre o container e o sistema, enquanto a rede none remove a interface de rede.

# Copia e roda um container com banco de dados MongoDB adicionando na minha rede criada
docker run -d --network giovanni-bridge --name meu-mongo mongo:4.4.6

# Copia e roda um container de aplicação que usa a mesma rede para comunicação com MongoDB
# Acessar a aplicação em localhost:3000, popular banco em /seed e voltar para localhost:3000
# para ver os registros
docker run -d --network giovanni-bridge --name giovannicars -p 3000:3000 giovanni/giovanni-cars:1.0

# instalar Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# verificar versao do Docker Compose
docker compose version

# mostrar opcoes de docker Compose
docker compose

# O Docker Compose irá resolver o problema de executar múltiplos containers de uma só vez e de maneira coordenada, evitando executar cada comando de execução individualmente


# o arquivo docker-compose tem as definições do ambiente de composição para executar 
# as duas aplicações com suas respectivas configurações e imagens.
# docker-compose.yml

# na pasta que esta o arquivo docker-compose.yml, executar arquivo compose
# o nome da bridge deve ser compose-bridge no .yml e -d se não quiser ver a execução
# com logs ao baixar usando ctrl+c não remove a rede
docker compose up
ocker compose up -d

# mostra os serviços criados com o docker compose
docker compose ps

# remove os containers e rede criada entre eles 
docker compose down


