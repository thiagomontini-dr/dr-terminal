# Plugins do Oh My Zsh

Guia rápido dos plugins ativados no `~/.zshrc`, com uma breve explicação e como usar cada um.

> Criado em: 2026-07-10
> Última atualização: 2026-07-10

> Observação: o `zoxide` (seção final) não é um plugin do Oh My Zsh, mas uma ferramenta à parte carregada manualmente no `~/.zshrc`. Está documentado aqui por conveniência.

A ordem de carregamento importa: `zsh-syntax-highlighting` e `zsh-history-substring-search` devem ser sempre os dois últimos (nesta ordem), conforme a documentação oficial.

## Índice

| Plugin | Categoria | Resumo |
|--------|-----------|--------|
| git | Git | Aliases e funções para Git |
| git-auto-fetch | Git | `git fetch` automático em segundo plano |
| fzf | Busca | Integração com o fuzzy finder |
| macos | Sistema | Utilitários específicos do macOS |
| sudo | Sistema | Prefixa o comando com `sudo` (ESC ESC) |
| extract | Arquivos | Extrai qualquer arquivo compactado com um comando |
| copypath | Área de transferência | Copia o caminho atual |
| copyfile | Área de transferência | Copia o conteúdo de um arquivo |
| copybuffer | Área de transferência | Copia a linha de comando atual (Ctrl+O) |
| dirhistory | Navegação | Navega no histórico de diretórios com Alt+setas |
| web-search | Busca | Pesquisa na web direto do terminal |
| colored-man-pages | Exibição | Colore as páginas do `man` |
| command-not-found | Sistema | Sugere pacote quando o comando não existe |
| zsh-completions | Completions | Completions extras para vários comandos |
| zsh-autosuggestions | Produtividade | Sugestões baseadas no histórico enquanto digita |
| zsh-syntax-highlighting | Exibição | Colore comandos válidos e inválidos ao digitar |
| zsh-history-substring-search | Histórico | Busca no histórico por trecho digitado |
| zoxide (externo) | Navegação | `cd` inteligente por trecho do nome da pasta |

---

## Git e versionamento

### git

Fornece dezenas de aliases para Git. Os mais usados:

- `gst` → `git status`
- `gco` → `git checkout`
- `gcb` → `git checkout -b` (cria e troca de branch)
- `gaa` → `git add --all`
- `gcmsg "msg"` → `git commit -m "msg"`
- `gp` → `git push`
- `gl` → `git pull`
- `gd` → `git diff`
- `glog` → `git log --oneline --decorate --graph`

Listar todos: `alias | grep "='git"`.

### git-auto-fetch

Executa `git fetch` automaticamente em segundo plano enquanto você trabalha, mantendo o repositório atualizado com o remoto.

- Pausar temporariamente: `git-auto-fetch` (alterna ligado/desligado no diretório atual).
- O intervalo padrão é de 60 segundos.

---

## Busca

### fzf

Integra o fuzzy finder ao shell.

- `Ctrl+R` → busca interativa no histórico de comandos.
- `Ctrl+T` → insere arquivo/pasta selecionado na linha de comando.
- `Alt+C` → entra (`cd`) em um diretório escolhido interativamente.
- `comando **<TAB>` → completação fuzzy (ex.: `cd **<TAB>`, `vim **<TAB>`).

### web-search

Pesquisa na web pelo terminal, abrindo o navegador.

- `google termo de busca`
- `ddg termo` (DuckDuckGo)
- `github repositorio`
- `stackoverflow erro`

---

## Sistema

### macos

Utilitários do macOS. Comandos úteis:

- `ofd` → abre o Finder no diretório atual.
- `pfd` → imprime o caminho da janela do Finder em foco.
- `cdf` → entra no diretório aberto no Finder.
- `showfiles` / `hidefiles` → mostra/esconde arquivos ocultos no Finder.
- `rmdsstore` → remove arquivos `.DS_Store` recursivamente.

### sudo

Pressione `ESC` duas vezes para adicionar (ou remover) `sudo` no início da linha de comando atual. Útil quando um comando falha por falta de permissão.

### command-not-found

Quando você digita um comando que não existe, sugere o pacote (Homebrew) que o fornece.

---

## Arquivos e área de transferência

### extract

Extrai qualquer arquivo compactado com um único comando, sem lembrar as flags de cada formato.

- `extract arquivo.tar.gz`
- `extract arquivo.zip`
- Suporta `.tar`, `.gz`, `.bz2`, `.zip`, `.rar`, `.7z`, entre outros.

### copypath

- `copypath` → copia o caminho absoluto do diretório atual para a área de transferência.
- `copypath arquivo.txt` → copia o caminho do arquivo indicado.

### copyfile

- `copyfile arquivo.txt` → copia o conteúdo do arquivo para a área de transferência.

### copybuffer

- `Ctrl+O` → copia a linha de comando que está sendo digitada para a área de transferência.

---

## Navegação

### dirhistory

Navega pelo histórico de diretórios visitados com o teclado:

- `Alt+←` / `Alt+→` → volta/avança no histórico de diretórios.
- `Alt+↑` → sobe um nível (diretório pai).
- `Alt+↓` → desce para um subdiretório recém-visitado.

---

## Exibição

### colored-man-pages

Aplica cores às páginas de manual, facilitando a leitura. Basta usar `man comando` normalmente.

### zsh-syntax-highlighting

Colore os comandos enquanto você digita:

- Verde → comando válido/encontrado.
- Vermelho → comando inexistente ou com erro de sintaxe.

Ajuda a identificar erros antes de pressionar Enter. Não requer configuração.

---

## Produtividade e histórico

### zsh-completions

Adiciona completions (sugestões com `TAB`) para centenas de comandos e ferramentas que o Zsh não cobre por padrão. Uso transparente: apenas pressione `TAB`.

### zsh-autosuggestions

Enquanto você digita, sugere em cinza-claro o comando mais provável com base no histórico.

- `→` (seta direita) ou `End` → aceita a sugestão completa.
- `Ctrl+→` → aceita apenas a próxima palavra da sugestão.

### zsh-history-substring-search

Busca no histórico por um trecho digitado. Digite parte de um comando e navegue pelas ocorrências:

- `Ctrl+P` → resultado anterior (configurado no `.zshrc`).
- `Ctrl+N` → próximo resultado (configurado no `.zshrc`).
- No modo vi: `k` / `j` em modo comando.

Está configurado para retornar apenas resultados únicos (`HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1`).

---

## Ferramenta externa

### zoxide

Não é um plugin do Oh My Zsh, mas uma ferramenta à parte carregada no final do `~/.zshrc`:

```bash
eval "$(zoxide init zsh --cmd cd)"
```

Por causa de `--cmd cd`, neste setup o zoxide substitui o próprio `cd` (não usa o comando `z`). Ele memoriza as pastas visitadas e permite voltar a elas digitando apenas um trecho do nome.

Como funciona: entre em uma pasta uma vez pelo caminho completo; depois ela fica disponível como atalho de qualquer lugar.

```bash
cd ~/projetos/dr-terminal   # primeira visita, caminho normal
cd terminal                 # depois, pula direto para ~/projetos/dr-terminal
```

Comandos e truques:

- `cd trecho` → vai para a melhor pasta que casa com o trecho.
- `cd foo bar` → casa com `foo` e `bar` no caminho ao mesmo tempo.
- `cdi trecho` → modo interativo: abre uma lista (fzf) para escolher.
- `cd -` → volta para a pasta anterior.
- `cd` (sozinho) → vai para a home, como o `cd` tradicional.

O ranking usa "frecency" (frequência de uso + quão recente foi o acesso): quanto mais você usa uma pasta, mais fácil chegar nela.

Limitação: o zoxide só encontra pastas que você já visitou pelo menos uma vez. Pastas novas precisam ser acessadas pelo caminho completo antes de virarem atalho.

#### Popular o histórico de uma vez (máquina nova)

Para não precisar visitar cada pasta manualmente, o repositório inclui o script `scripts/seed-zoxide.sh`, que registra as pastas-pai indicadas e todas as suas subpastas de primeiro nível no banco do zoxide.

```bash
# pastas padrão: Projects, Desktop, Documents, Downloads
./scripts/seed-zoxide.sh

# ou informando suas próprias pastas-pai
./scripts/seed-zoxide.sh Projects Work ~/dev /opt/apps
```

Os caminhos podem ser relativos à `HOME` (`Projects`), com `~` (`~/dev`) ou absolutos (`/opt/apps`). Pastas inexistentes na máquina são ignoradas, então a mesma lista funciona em máquinas diferentes. O script usa `zoxide add` (método interno do zoxide) e exige que o zoxide já esteja instalado.

Depois de rodar, todas as subpastas começam com o mesmo peso (frecency); conforme você usa, as mais frequentes sobem no ranking.

---

## Aplicar mudanças

Após editar o `~/.zshrc`, recarregue com:

```bash
reload
# ou
source ~/.zshrc
```
