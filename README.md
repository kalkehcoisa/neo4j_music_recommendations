# Recomendações Musicais com Neo4j

Neste pequeno projeto simulo um pipeline completo para construir um grafo de músicas e calcular
semelhanças entre elas utilizando o [Neo4j](https://neo4j.com/). Como o poder de processamento
e limite de nós do Aura (200mil), acabou atrapalhando bastante, optei por usar Neo4j na minha
máquina, de dentro de um container Docker; o script: [neo4j-docker.sh](./neo4j-docker.sh) cuida
dessa parte. Mais detalhes sobre adiante.

## Estrutura do repositório

```
.gitignore
musicas_similares.csv          ← ficheiro CSV final usado nas queries
neo4j-docker.sh                ← script para arrancar um container Neo4j
run_cypher.sh                  ← executa em sequência os scripts Cypher
cypher/
  00_import_data.cypher
  01_genres_tags.cypher
  02_clean_normalize.cypher
  03_calc_similarities.cypher
  04_return_similar_songs.cypher
dataset/
  clean_data.sh                ← utilitário para converter/limpar o dump original
  filter_music.py              ← filtra o dataset por parâmetros (não usados)
  musicas_similares.csv        ← resultado do filtro
```

## Neo4j (via Docker)

Para não instalar o Neo4j localmente utilizei um container Docker. O script
`neo4j-docker.sh` inicia esse container com as configurações mínimas
necessárias.

Esse script faz o seguinte:

- baixa a imagem oficial `neo4j:latest` (se ainda não existir localmente);
- define a password padrão `neo4j` (alterável via variável de ambiente);
- expõe as portas **7474** (browser/HTTP) e **7687** (Bolt);
- mantém o container em segundo plano para que os scripts Cypher possam
  conectar‑se com `cypher-shell`.

Se preferir, pode abrir o browser em <http://localhost:7474> e verificar
que a base de dados está a correr.

Muito provavelmente, você terá que baixar o Plugin GDS (graph data science).
Ele não é instalado automaticamente. Consegui encontrá-lo nas releases no
[github do projeto](https://github.com/neo4j/graph-data-science/releases).
Baixei e coloque-o em */$DATA_DIR/plugins/*. Verifique no script *neo4j-docker.sh*.


## Scripts Cypher

O ficheiro `run_cypher.sh` executa, numa instância do `cypher-shell`, todos os scripts do
directório `cypher/`. Cada passo está numerado e comentado para facilitar depuração; basta
comentar a linha correspondente se quiser executar apenas parte do pipeline.

### `00_import_data.cypher`

- Importa o `musicas_similares.csv` para o grafo
- Cria nós `:Song` com propriedades básicas (`title`, `artist`, `year`, etc.)
- Cria nós `:Genre` e `:Tag` e associa‑os às músicas, usando `MERGE` para evitar duplicados
- Cria relações simples `(:Song)-[:HAS_GENRE]->(:Genre)` e `(:Song)-[:HAS_TAG]->(:Tag)`

### `01_genres_tags.cypher`

- Após a importação, normaliza e deduplica géneros e tags
- Por exemplo, converte "rock" e "Rock" para o mesmo nó, remove espaços em branco
- Adiciona índices/constraints adicionais (`:Genre(name)` único, etc.)
- Cria relações adicionais quando uma tag deve ser tratada como género ou vice‑versa

### `02_clean_normalize.cypher`

- Limpa texto das propriedades (`trim`, `toLower`, etc.)
- Remove nós órfãos (músicas sem título, géneros vazios, etc.)
- Standardiza valores numéricos (ex.: transforma `year` em inteiro)
- Qualquer outra normalização que facilite as queries de similaridade

### `03_calc_similarities.cypher`

- Calcula a semelhança entre músicas com base em:
  - géneros em comum
  - tags/keywords partilhadas
  - (poderia ser estendido para intersecção de utilizadores, playcounts, etc.)
- Cria relações `[:SIMILAR {dist: …}]` entre pares de músicas ordenadas pelo peso
- Este passo é o "core" do sistema de recomendações; os algoritmos de cálculo podem ser
  adaptados/experimentados

### `04_return_similar_songs.cypher`

- Exemplo de query final que, dada uma música ou título, retorna as N músicas mais
  semelhantes ordenadas pelo `dist`
- Inclui propriedades úteis para apresentação (artista, álbum, ano, etc.)
- O próprio `run_cypher.sh` já imprime o resultado desta última query como demonstração

## Utilização

1. Preparar o CSV (`dataset/...`);
2. Arrancar o Neo4j:
   ```bash
   ./neo4j-docker.sh
   ```
3. Executar os scripts Cypher:
   ```bash
   ./run_cypher.sh
   ```
4. (Opcional) abrir o browser em <http://localhost:7474> e navegar/manipular o grafo manualmente.

> Se, por exemplo, só quiser recalcular as similaridades depois de ter adicionado novas músicas,
> basta comentar as chamadas a `00_import_data.cypher` no `run_cypher.sh`.

### Resultado
O resultado é salvo em **/$DATA_DIR/import/musicas_similares.csv**. O APOC usa o diretório padrão
para troca de arquivos montado no docker. Não temos como escolher no caso.
O arquivo exibe uma lista com músicas em ordem decrescente de popularidade seguida de, até 20
músicas mais similares, por ordem de similaridade.
Aqui está um trecho do arquivo [musicas_similares.csv](./musicas_similares.csv):
````
"Revelry","Kings of Leon","Born Like This","Three Days Grace","0.2"
"Revelry","Kings of Leon","Gibberish","Spock's Beard","0.20689655172413793"
"Revelry","Kings of Leon","Always The Love Songs","Eli Young Band","0.21212121212121213"
"Revelry","Kings of Leon","The Way I Loved You","Taylor Swift","0.21212121212121213"
"Revelry","Kings of Leon","Dead Sound","The Raveonettes","0.21212121212121213"
"Revelry","Kings of Leon","The Way I Loved You","Taylor Swift","0.21428571428571427"
...
````

## Observações

- O projeto está concluído: o pipeline importa os dados, monta o grafo, normaliza e gera
  relações de semelhança; a query final devolve sugestões plausíveis.
- Pode ser estendido adicionando mais parâmetros de filtragem no `filter_music.py` ou mais
  passos de processamento/algoritmos nos scripts Cypher.
- Os scripts são intencionalmente simples para servir de exemplo didático.
