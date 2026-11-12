# Antonio - Conexão e CRUD de planos

Conexão com o MySQL e CRUD de planos em Python: cadastrar, listar, buscar por ID, atualizar e excluir.

## Como rodar

Precisa de Python 3.10 ou superior e do MySQL com o `sql/01-modelo-fisico.sql` já executado (uma vez, em banco novo, pelo Workbench).

Na pasta do projeto, criar e ativar o ambiente virtual:

```console
python -m venv .venv
```

No PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

No Linux/macOS:

```sh
source .venv/bin/activate
```

Instalar a dependência:

```console
python -m pip install -r requirements.txt
```

Copiar `config.example.ini` para `config.ini` e preencher usuário e senha do MySQL local. O `config.ini` não vai para o GitHub.

A conta usada precisa de SELECT, INSERT, UPDATE e DELETE na tabela `plano`.

Para iniciar:

```console
python main.py
```

## O que testar

- Criar um plano, listar e buscar pelo ID.
- Atualizar o nome do plano.
- Tentar criar com duração zero (deve recusar).
- Cancelar uma exclusão e ver se o plano continua lá.
- Excluir o plano de teste e buscar de novo.
- Tentar excluir um plano que já tem instituição ligada a ele (a chave estrangeira não deixa).
- Reduzir a cota para menos do que já está em uso (a trigger do modelo físico barra).

## Observações

Não tem login de usuário na aplicação. Todas as operações usam a conta do MySQL que está no `config.ini`.