# Hellyne - Views de empresa e administrador

Segunda parte das views. São 13 no total, todas só de consulta.

## Empresa

| View | O que mostra |
|---|---|
| vw_empresa_usuarios | Usuários da mesma instituição do representante conectado |
| vw_empresa_arquivos | Arquivos ativos desses usuários, conforme o acesso institucional do enunciado |

A conta da empresa precisa ter o mesmo nome do login de um usuário que represente a instituição. O vínculo usa o `usuario.id_instituicao` que já existe, sem cadastro paralelo. O filtro por instituição sozinho não separa funcionário de representante, então o `SELECT` nessas views só pode ir para a PapelEmpresa, e quem monta as roles precisa atribuir isso com cuidado. Mudar o vínculo de instituição ou o login do representante deve ficar restrito ao administrador.

## Administrador

São onze views: `vw_admin_usuarios`, `vw_admin_arquivos`, `vw_admin_planos`, `vw_admin_instituicoes`, `vw_admin_administradores`, `vw_admin_compartilhamentos`, `vw_admin_comentarios`, `vw_admin_suporte`, `vw_admin_atendimentos`, `vw_admin_operacoes` e `vw_admin_versoes`.

A conexão precisa corresponder a um `usuario.login` que esteja na tabela `administrador`. Se não estiver, as views retornam zero linhas. O `SELECT` deve ir só para a role administrativa.

Nenhuma view mostra colunas de ID nem hash de senha. A `vw_admin_versoes` não traz o conteúdo livre do versionamento, porque ele pode ter referências internas em JSON ou texto. Os textos livres cadastrados pelos usuários não são tratados. Nomes podem repetir, então as views servem para consulta e não como chave para edição.

A tabela `atividades_recentes` continua fora das views, já que só o root pode acessá-la.

## Identidade e permissões

Vale o mesmo combinado das views do usuário: uma conta MySQL por pessoa, com nome igual ao `usuario.login`, sem `@`, sem conta anônima, proxy ou conta compartilhada, e com comparação que diferencia maiúsculas de minúsculas. Contas com o mesmo nome em hosts diferentes devem ser da mesma pessoa. O Python atual não faz login individual, então estas views só se testam no Workbench com conexões separadas.

As views usam `SQL SECURITY DEFINER`, então quem criou precisa ter os privilégios de leitura e continuar existindo. A identificação vem de `USER()`, nunca de `@id_usuario`. Não dar `SELECT` direto nas tabelas base para usuários ou empresas, e não liberar as views de administrador para outras roles. Nenhum GRANT é dado por este script.

## Como rodar

Conectado como root no banco de desenvolvimento, com o modelo físico e o `sql/04-views-usuario.sql` já executados, rodar `sql/05-views-empresa-admin.sql`. Não rode o modelo físico de novo. O script cria as views uma vez e não substitui as que já existem.

## Testes

Depois de criar as contas e as roles:

1. Conectar como representante da instituição A: as views de empresa mostram só usuários e arquivos da A.
2. Conectar como representante da B: nada da A aparece.
3. Conectar como funcionário sem PapelEmpresa: o `SELECT` nas views de empresa deve ser negado.
4. Conectar como administrador cadastrado: conferir as 11 views de administrador e a ausência de IDs e senhas.
5. Como usuário comum, o `SELECT` nas views de administrador deve ser negado. Como conta com `SELECT` mas sem vínculo na tabela `administrador`, elas devem retornar zero linhas.
6. `UPDATE`, `INSERT` e `DELETE` nas views devem falhar, e `atividades_recentes` deve continuar inacessível para quem não é root.
7. Em `information_schema.VIEWS`, `IS_UPDATABLE` deve ser NO em todas as views criadas.

Eu não consegui rodar estes testes num servidor MySQL, então vale executar no Workbench antes do merge. As permissões ficam para a etapa de roles.
