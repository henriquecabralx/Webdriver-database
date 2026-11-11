# Entrega 1 — Conexão e CRUD de planos

Esta entrega corresponde ao primeiro commit do integrante 1. Contém conexão compartilhada, cadastro, listagem, busca por ID, atualização e exclusão de planos. Não implementa os demais módulos nem a Parte 2.

## Preparação

1. Copie os arquivos deste pacote para a raiz do repositório existente. Preserve o README, docs e SQL já existentes. Mescle o conteúdo de `.gitignore` se ele tiver outras regras.
2. Instale Python 3.10 ou superior e MySQL compatível com o modelo físico.
3. Execute o modelo físico existente, uma vez em banco novo, no MySQL Workbench. Este programa não cria nem substitui o banco.
4. No terminal, dentro da pasta do projeto, execute:

```console
python -m venv .venv
```

No Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

No Linux/macOS:

```sh
source .venv/bin/activate
```

Instale a dependência:

```console
python -m pip install -r requirements.txt
```

Copie `config.example.ini` para `config.ini` e preencha usuário e senha do MySQL local. A conta precisa de SELECT, INSERT, UPDATE e DELETE em plano; a atualização também executa as validações do modelo físico. Não envie `config.ini` para o GitHub.

Inicie:

```console
python main.py
```

## Conferência no ambiente do grupo

- Crie um plano de teste com 30 dias e 1048576 bytes.
- Liste e busque pelo ID retornado.
- Atualize seu nome; repita a atualização com os mesmos valores.
- Tente duração zero: deve ser recusada.
- Cancele uma exclusão; confirme que o plano permanece.
- Exclua o plano de teste, confirme e busque novamente.
- Em ambiente de teste, tente excluir um plano vinculado a uma instituição: a FK deve impedir.
- Confira que a trigger existente rejeita redução de cota abaixo do uso atual.

## Commit

Envie `.gitignore`, `config.example.ini`, `requirements.txt`, `main.py`, a pasta `webdriver` e este documento. Não envie `.venv`, `__pycache__` ou `config.ini`.

Mensagem: `Adiciona conexão MySQL e CRUD de planos em Python`.

## Validação e escopo

Validação estática de sintaxe realizada na preparação. A execução contra MySQL depende da instância e das credenciais do grupo; não foi validada neste ambiente. Interface local acadêmica, sem login de usuários da plataforma. Todas as ações usam a conta MySQL configurada.

Referências oficiais do conector: https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlcursor-execute.html e https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlconnection-commit.html.
