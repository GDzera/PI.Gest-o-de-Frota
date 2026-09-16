# Plataforma de Gestão de Frota

Sistema web completo (PHP + MySQL) para gestão e controle de frota de veículos
leves: cadastro de veículos e condutores, manutenções preventivas (regra de
10.000 km) e corretivas, solicitações feitas pelo condutor, dashboard
gerencial, indicadores/ranking, oficinas credenciadas, relatórios e
notificação por WhatsApp ao Gestor da Frota.

## Instalar como aplicativo (celular e computador)

O sistema é um PWA (Progressive Web App): dá para "instalar" ele como se fosse
um aplicativo de verdade, com o ícone do Saffrix Fleet, sem precisar de loja
de aplicativos.

- **Celular Android / computador com Chrome ou Edge**: acesse a tela de
  login normalmente. Vai aparecer um botão **"📲 Instalar aplicativo neste
  dispositivo"** — é só tocar/clicar nele. O navegador também pode mostrar
  esse mesmo convite sozinho (ícone de instalação na barra de endereço).
- **iPhone/iPad (Safari)**: o iOS não permite instalar automaticamente.
  Acesse a tela de login, toque no ícone de **Compartilhar** (o quadrado com
  a seta para cima) e depois em **"Adicionar à Tela de Início"**.

Depois de instalado, o ícone do Saffrix Fleet aparece na tela inicial do
celular ou no menu de programas do computador, abrindo direto na tela de
login (ou já no dashboard, se a sessão ainda estiver ativa), sem barra de
endereço, como um aplicativo nativo.

## Requisitos

- PHP 8.0 ou superior, com as extensões `pdo_mysql` e `curl` habilitadas
- MySQL ou MariaDB 10.4+
- Um servidor web (Apache/Nginx) ou o servidor embutido do PHP para testes
- Mais simples: um pacote como **XAMPP** ou **WAMP**, que já traz tudo isso pronto

## Instalação passo a passo

1. **Copie a pasta `crud_frota` inteira** para dentro da pasta pública do seu
   servidor (no XAMPP, geralmente `C:\xampp\htdocs\`).

2. **Crie o banco de dados.** Abra o phpMyAdmin (ou o cliente MySQL de sua
   preferência) e importe o arquivo `database/schema.sql`. Ele já cria o
   banco `frota_db`, todas as tabelas e um usuário de teste.

   Pela linha de comando, seria assim:
   ```
   mysql -u root -p < database/schema.sql
   ```

3. **Configure a conexão com o banco** em `config/database.php`, ajustando
   host, usuário e senha do seu MySQL (por padrão já está configurado para
   o padrão do XAMPP: usuário `root`, sem senha).

4. **Acesse o sistema** pelo navegador, por exemplo:
   ```
   http://localhost/crud_frota/auth/login.php
   ```

5. **Faça login com o usuário de teste** (Gestor da Frota):
   - E-mail: `admin@frota.com`
   - Senha: `admin123`

   **Altere essa senha assim que possível** (crie um novo usuário gestor de
   verdade e/ou use "Esqueci minha senha" para trocar a senha do admin).

## Notificações via WhatsApp

O envio de mensagens de WhatsApp depende de uma API externa (não existe API
oficial e gratuita do WhatsApp para isso). O arquivo `includes/whatsapp.php`
já vem pronto para dois provedores comuns — basta preencher as constantes no
topo do arquivo com as credenciais da sua conta:

- **CallMeBot** — gratuito, simples, bom para poucos avisos e testes.
  Instruções: https://www.callmebot.com/blog/free-api-whatsapp-messages/
- **Twilio** — pago, mais robusto para uso comercial.
  Instruções: https://www.twilio.com/whatsapp

Enquanto nenhum provedor estiver configurado, todas as notificações
continuam sendo registradas na tabela `notificacoes_whatsapp`, então nada se
perde — elas só não são efetivamente enviadas ao celular do gestor.

## Estrutura de pastas

```
crud_frota/
├── auth/               → login, logout, recuperação de senha
├── config/             → conexão com o banco de dados
├── controllers/        → lógica de cada módulo (um arquivo por aba do sistema)
├── includes/           → funções auxiliares (sessão, permissões, WhatsApp)
├── views/               → telas (HTML/PHP) organizadas por módulo
├── assets/             → CSS e arquivos estáticos
├── database/schema.sql → estrutura completa do banco de dados + dados iniciais
└── index.php           → roteador principal (todas as telas internas passam por aqui)
```

## Perfis de usuário

- **Gestor da Frota**: cadastra veículos, condutores e oficinas; acompanha e
  aprova solicitações; registra manutenções concluídas; acessa dashboard,
  indicadores e relatórios.
- **Condutor**: só enxerga o veículo vinculado a ele; solicita manutenção
  informando a quilometragem atual; acompanha o status das próprias
  solicitações.

Para cadastrar um condutor, use o próprio sistema como Gestor
(**Condutores → + Novo Condutor**) — o cadastro já cria o acesso de login
dele automaticamente.

## Regra de manutenção preventiva

Por padrão, a próxima manutenção preventiva é calculada somando 10.000 km à
quilometragem da última manutenção. Esse intervalo pode ser ajustado por
veículo (campo "Intervalo de manutenção" no cadastro do veículo), caso algum
veículo específico precise de um intervalo diferente.

## Segurança implementada

- Senhas armazenadas com hash (bcrypt), nunca em texto puro
- Todas as consultas ao banco usam parâmetros preparados (proteção contra
  injeção de SQL)
- Proteção CSRF em todos os formulários
- Controle de acesso por perfil em todas as telas (um condutor não consegue
  acessar telas do gestor digitando a URL diretamente, e vice-versa)
- Um condutor só acessa dados do próprio veículo, nunca de outros

## Possíveis evoluções futuras

- Autenticação de dois fatores para o Gestor da Frota
- Envio de e-mail real na recuperação de senha (hoje o link aparece na tela,
  já que não há servidor de e-mail configurado neste ambiente de exemplo)
- Anexar fotos/notas fiscais às manutenções
- Aplicativo mobile dedicado para o condutor
