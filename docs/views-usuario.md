# Hellyne - Views do usuário

Duas views de consulta para o usuário:

| View | O que mostra |
|---|---|
| vw_arquivos_autorizados | Arquivos ativos do próprio usuário, os públicos e os compartilhados com ele |
| vw_historico_usuario | Operações feitas pelo próprio usuário, inclusive em arquivos removidos |

Nenhuma das duas mostra IDs nem senhas. No histórico, cada usuário vê só as próprias operações, sem expor a atividade de outras pessoas. As views não mexem no CRUD em Python.

## Como a view sabe quem é o usuário

O banco não liga a conexão do MySQL ao usuário da aplicação. Para a demonstração, cada usuário usa uma conta MySQL com o nome igual ao `usuario.login`, e as views leem esse nome com `USER()`. Não usei `CURRENT_USER()` porque, numa view DEFINER, ele devolve o criador da view, e variáveis de sessão como `@id_usuario` o próprio usuário pode alterar.

Exemplo: o login `ana` só enxerga os dados dela se consultar pela conta MySQL `ana`. Inserir `ana` na tabela `usuario` não basta.

Cuidados:

- Os logins não podem ter `@`.
- A comparação de login diferencia maiúsculas de minúsculas.
- Não usar conta anônima, proxy nem conta compartilhada.
- Conta MySQL sem usuário correspondente na tabela retorna zero linhas.

O Python continua usando uma conta única do `config.ini`, então as views só podem ser testadas no Workbench com conexões individuais.

## Como rodar

Conectado como root, no banco que já tem o modelo físico, executar `sql/04-views-usuario.sql`. O script cria as views uma vez e não substitui views que já existam. O definidor é a conta que rodar o script e precisa continuar existindo.

## Permissões

As views usam `ALGORITHM = TEMPTABLE`, então não são atualizáveis. O usuário deve receber só `SELECT` nelas, sem acesso direto às tabelas base, porque permissão direta na tabela não passa pelo filtro da view. Isso resolve a consulta, mas não os direitos de inserir e atualizar do `PapelUsuario`, que precisam de procedures com validação de identidade e das roles.

As procedures de arquivos recebem o ID por parâmetro e não conferem quem está chamando. Dar EXECUTE a contas comuns não basta para dizer que a autorização da Parte 2 está pronta. Isso fica para quem for montar as roles.

## Testes

Como root, conferir as colunas e se as views são atualizáveis:

```sql
SHOW COLUMNS FROM webdriver.vw_arquivos_autorizados;
SHOW COLUMNS FROM webdriver.vw_historico_usuario;
SELECT TABLE_NAME, IS_UPDATABLE
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'webdriver'
  AND TABLE_NAME IN ('vw_arquivos_autorizados', 'vw_historico_usuario');
```

Não deve haver coluna de ID, e `IS_UPDATABLE` deve ser NO nas duas.

Depois de criar as contas e dar `SELECT` nas views, crie como root dois usuários, um arquivo privado de cada um, um público e um compartilhado com convite para só um deles. Conectado como cada usuário:

```sql
SELECT USER();
SELECT * FROM webdriver.vw_arquivos_autorizados;
SELECT * FROM webdriver.vw_historico_usuario;
```

O que conferir:

- Não aparece o arquivo privado do outro usuário.
- O compartilhado só aparece para quem foi convidado. Remova o convite como root e consulte de novo: ele deve sumir.
- O público aparece para todos.
- Arquivo removido não aparece na view de arquivos.
- O histórico mostra só as operações do próprio usuário.
- Conta sem usuário correspondente retorna zero linhas.
- INSERT, UPDATE e DELETE nas views, e SELECT direto nas tabelas base, são recusados.

Eu não consegui rodar estes testes num servidor MySQL, então vale executar no Workbench antes do merge.
