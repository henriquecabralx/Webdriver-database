# Lucas - Roles, permissões e objetos da Parte 2

Implementa as três roles e os objetos que faltavam (procedures, função e triggers), mantendo `atividades_recentes` acessível só ao root. Não recriei o banco nem mexi no CRUD já existente.

| Objeto | O que faz |
|---|---|
| PapelUsuario | Consulta as views do usuário e carrega/atualiza os próprios arquivos por procedures |
| PapelEmpresa | Só leitura das views da própria instituição |
| PapelAdm | Leitura, inserção, atualização e exclusão em todas as tabelas, exceto `atividades_recentes` |
| Verificar_atividades | Atualiza toda `atividades_recentes` com a data atual |
| Conta_usuários | Recebe o ID de um arquivo e conta os usuários com acesso |
| Chavear | Alterna PRIORITARIO e NAO_PRIORITARIO (já existia, mantida) |
| Remover_acessos | Remove o acesso de todos, menos o do proprietário |
| fn_arquivo_inativo | Retorna 1 se a última alteração tem mais de 100 dias, senão 0 |
| Safe_security | Impede a inserção de arquivos executáveis |
| Registrar_operacao | Atualiza a data em `atividades_recentes` a cada nova operação |
| Atualizar_acesso | Atualiza o registro do arquivo quando um usuário ganha acesso |

## Alterações por pasta

**sql/**

- `03-procedures-atividades.sql` (alterado): `Verificar_atividades` perdeu o parâmetro e passou a atualizar a tabela inteira, como o enunciado pede.
- `06-procedures-permissoes.sql` (novo): `Conta_usuários`, `Remover_acessos`, `usr_carregar_arquivo` e `usr_atualizar_arquivo`.
- `07-funcoes-triggers.sql` (novo): `fn_arquivo_inativo`, `fn_arquivo_executavel` (auxiliar), `Safe_security`, `Safe_security_update`, `Registrar_operacao`, `Atualizar_acesso` e `Atualizar_acesso_update`.
- `08-roles-permissoes.sql` (novo): cria as roles e concede os privilégios por objeto.

**webdriver/** (e `main.py`)

- `perfil.py` (novo): lê a role e a conta ativas no MySQL (`CURRENT_ROLE()`, `CURRENT_USER()`) para definir o perfil. O operador não escolhe.
- `usuario.py` e `empresa.py` (novos): consultam as views e, no caso do usuário, chamam as procedures `usr_*`. Nenhum ID é enviado.
- `administracao.py` (novo): chama `Conta_usuários`, `Remover_acessos`, `Verificar_atividades` e `Chavear`.
- `main.py` (alterado): mostra o menu conforme o perfil. O CRUD anterior (`repositorio`, `arquivos`, `planos`, `historicos`) não mudou.

**tests/**

- `test_parte2.py` (novo): testes unitários sem MySQL (perfil, módulos de usuário, empresa e administração).
- `test_seguranca_mysql.py` (novo): testes de integração em MySQL real, num banco descartável `webdriver_teste`.

Também foram alterados `README.md` e `docs/` (este arquivo e `parte2-permissoes.md`).

## Como a identidade é garantida

As views e as procedures `usr_*` usam `USER()`, que é a conta MySQL com nome igual ao `usuario.login`. As `usr_*` não têm parâmetro de ID: o dono é sempre a conta conectada, e o arquivo é localizado pelo nome entre os ativos do próprio usuário. As procedures `sp_*`, que recebem IDs, não são concedidas a usuário nem a empresa.

`Conta_usuários` e `Remover_acessos` validam também a conta autenticada (`CURRENT_USER()`): só root ou quem estiver em `administrador`. Ter a role não basta.

## Como rodar

Conectado como root, com `--default-character-set=utf8mb4` (o nome `Conta_usuários` tem acento), executar na ordem `sql/01` a `sql/08`. O 08 vem por último porque `GRANT EXECUTE` exige que as rotinas já existam. Banco que já rodou o `03` antigo precisa recriar `Verificar_atividades`.

Cada pessoa precisa de conta própria e de role ativa:

```sql
CREATE USER 'ana'@'localhost' IDENTIFIED BY 'senha';
GRANT PapelUsuario TO 'ana'@'localhost';
SET DEFAULT ROLE PapelUsuario TO 'ana'@'localhost';
```

Sem `SET DEFAULT ROLE` a role não fica ativa no login.

## Permissões

| Role | Concedido | Negado |
|---|---|---|
| PapelUsuario | `SELECT` em `vw_arquivos_autorizados` e `vw_historico_usuario`; `EXECUTE` em `usr_carregar_arquivo` e `usr_atualizar_arquivo` | Tabelas, `sp_*`, alterar o histórico |
| PapelEmpresa | `SELECT` em `vw_empresa_usuarios` e `vw_empresa_arquivos` | Qualquer escrita e outras instituições |
| PapelAdm | CRUD nas tabelas (menos `atividades_recentes`), `SELECT` nas `vw_admin_*`, `EXECUTE` em `sp_*`, `Conta_usuários`, `Remover_acessos` | `atividades_recentes`, `Verificar_atividades`, `Chavear` |

Não há `GRANT` em `webdriver.*` nem em `*.*`. `Verificar_atividades`, `Chavear` e `fn_arquivo_inativo` são `SQL SECURITY INVOKER`, então só o root as usa. Os triggers rodam com o privilégio do definidor e gravam na tabela restrita sem que as roles tenham acesso a ela.

## Interpretações e limites

- `Atualizar_acesso`: o enunciado não detalha a regra. Um novo compartilhamento cria ou atualiza o registro do arquivo em `atividades_recentes`, com a prioridade preservada.
- `Remover_acessos` também passa o arquivo a PRIVADO, senão um arquivo público continuaria acessível.
- `fn_arquivo_inativo` retorna 0 para arquivo sem registro de atividade.
- `Safe_security` bloqueia pela última extensão e pelo tipo; não analisa o conteúdo do arquivo.
- O usuário atualiza só arquivos próprios. Arquivo público ou compartilhado é leitura para o destinatário.
- O PapelAdm tem escrita direta em `arquivo`, o que permite contornar cota e auditoria das `sp_*`.
- Conta anônima do MySQL permitiria falsificar `USER()` e deve ser removida.

## Testes

```console
python -m unittest discover -s tests -v
WEBDRIVER_TEST_MYSQL=1 python -m unittest discover -s tests -v
```

O primeiro roda os testes unitários; o segundo inclui os de integração, que exigem MySQL 8.0.16+, o cliente `mysql` no PATH e uma conta root (variáveis `WEBDRIVER_TEST_ROOT_PASSWORD` e `WEBDRIVER_TEST_HOST` ou `WEBDRIVER_TEST_SOCKET`). Eles cobrem:

- Isolamento de arquivos privados, acesso a próprios e compartilhados, e bloqueio de atualização sem autorização.
- Isolamento entre empresas e empresa somente leitura.
- Operações do administrador e bloqueio das operações administrativas ao usuário comum.
- Nenhum acesso a `atividades_recentes` por nenhuma role.
- Histórico somente leitura e ausência de IDs nas views.
- Bloqueio de executáveis, procedures, função e triggers.

Executei 28 testes (18 unitários e 10 de integração) em MySQL 8.0.46 no Linux e todos passaram. Não executei no Workbench nem no Windows, então vale rodar no seu ambiente antes do merge.
