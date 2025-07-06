# Sistema de Save/Load - Documentação

## Arquivos Implementados

### 1. `scripts/Global.gd`
- **Função**: Gerenciador global de dados do jogo
- **Recursos**: 
  - Salvar/carregar progresso do jogador
  - Controlar checkpoint da fase
  - Gerenciar dados entre cenas

### 2. `main_menu.gd` (Atualizado)
- **Função**: Menu principal com botão carregar funcional
- **Recursos**:
  - Botão "Carregar" só fica ativo quando há save
  - Carrega automaticamente o progresso do checkpoint
  - Integra com sistema Global

### 3. `scripts/Level1Manager.gd`
- **Função**: Gerenciador da Fase 1
- **Recursos**:
  - Detecta se jogo foi carregado de checkpoint
  - Controla progressão entre puzzles
  - Salva checkpoint após segundo puzzle

### 4. `scripts/PuzzleManager.gd`
- **Função**: Detecta conclusão automática dos puzzles
- **Recursos**:
  - Monitora estado dos slots e itens
  - Detecta quando puzzles são completados
  - Comunica com Level1Manager

## Como Funciona

### Fluxo de Novo Jogo
1. Jogador clica "Novo Jogo"
2. Insere apelido
3. `Global.reset_game_data()` reseta variáveis
4. Carrega Level1 no primeiro puzzle

### Fluxo de Salvamento (Checkpoint)
1. Jogador completa Puzzle 1
2. Jogador completa Puzzle 2
3. `Level1Manager.save_checkpoint()` é chamado
4. `Global.save_game_at_checkpoint()` salva arquivo
5. Botão "Carregar" fica disponível no menu

### Fluxo de Carregamento
1. Jogador clica "Carregar" (se disponível)
2. `Global.load_game_data()` lê arquivo de save
3. Dados são restaurados
4. Level1 inicia no Puzzle 3 (checkpoint)

## Configuração Necessária

### 1. Project Settings
- ✅ Global.gd adicionado como AutoLoad
- ✅ PlayerData.gd mantido para compatibilidade

### 2. Conexões de Sinais
O sistema funciona principalmente por:
- Detecção automática de elementos (PuzzleManager)
- Comunicação via sinais entre scripts
- Verificação periódica de estado dos puzzles

### 3. Estrutura da Cena Level1
- ✅ Level1Manager.gd anexado ao nó principal
- ✅ PuzzleManager criado automaticamente
- Slots e itens detectados automaticamente

## Personalização

### Para Ajustar Detecção de Puzzles
Edite `PuzzleManager.gd`:
- `check_puzzle_1()`: Critério para completar puzzle 1
- `check_puzzle_2()`: Critério para completar puzzle 2
- `check_puzzle_3()`: Critério para completar puzzle 3

### Para Ajustar Posições de Checkpoint
Edite `Level1Manager.gd`:
- `position_player_at_start()`: Posição inicial
- `position_player_at_checkpoint()`: Posição do checkpoint

### Para Modificar Dados Salvos
Edite `Global.gd`:
- Função `save_game_at_checkpoint()`: Adicione mais dados
- Função `load_game_data()`: Leia dados adicionais

## Teste do Sistema

### Para Testar Salvamento:
1. Inicie novo jogo
2. Complete os dois primeiros puzzles
3. Verifique se aparece "Checkpoint alcançado!"
4. Volte ao menu principal
5. Botão "Carregar" deve estar ativo

### Para Testar Carregamento:
1. Com save disponível, clique "Carregar"
2. Deve carregar direto no terceiro puzzle
3. Jogador deve estar na posição do checkpoint

## Arquivos de Save
- **Local**: `user://savegame.dat`
- **Formato**: JSON
- **Conteúdo**: nickname, fase, checkpoint, puzzle atual, etc.

## Próximos Passos
1. Teste o sistema no Godot
2. Ajuste posições e critérios conforme necessário
3. Adicione mais fases seguindo o mesmo padrão
4. Implemente sistema de ranking (opcional)
