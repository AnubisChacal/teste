#!/bin/bash

exibir_banner() {
    echo -e "\e[38;5;208m" 
    cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠙⠻⢶⣄⡀⠀⠀⠀⢀⣤⠶⠛⠛⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣇⠀⠀⣙⣿⣦⣤⣴⣿⣁⠀⠀⣸⠇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣡⣾⣿⣿⣿⣿⣿⣿⣿⣷⣌⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣷⣄⡈⢻⣿⡟⢁⣠⣾⣿⣦⠀⠀  
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⠘⣿⠃⣿⣿⣿⣿⡏⠀⠀⠀ ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗    ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠈⠛⣰⠿⣆⠛⠁⠀⡀⠀⠀⠀⠀ ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝    ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣦⠀⠘⠛⠋⠀⣴⣿⠁⠀⠀⠀⠀⠀███████╗██╔████╔██║███████║██████╔╝   ██║       ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣾⣿⣿⣿⣿⡇⠀⠀⠀⢸⣿⣏⠀⠀⠀⠀⠀⠀╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║       ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠀⠀⠀⠾⢿⣿⠀⠀⠀⠀⠀⠀███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║       ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⡿⠟⠋⣁⣠⣤⣤⡶⠶⠶⣤⣄⠈⠀⠀⠀⠀⠀⠀╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
⠀⠀⠀⢰⣿⣿⣮⣉⣉⣉⣤⣴⣶⣿⣿⣋⡥⠄⠀⠀⠀⠀⠉⢻⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣋⣁⣤⣀⣀⣤⣤⣤⣤⣄⣿⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠋⠉⠁⠀⠀⠀⠀⠈⠛⠃⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
    echo -e "\e[0m"  # Reseta cor
}

# Detecta o formato do conteúdo
detectar_formato_arquivo() {
    local arquivo="$1"
    local amostra

    if grep -q $'\x00' "$arquivo" 2>/dev/null; then
        echo "arquivo_invalido"
        return
    fi

    amostra=$(head -n 20 "$arquivo" 2>/dev/null)

    if echo "$amostra" | grep -qE 'https?://.*:.*@.*\..*:.*'; then
        echo "formato_url_email_senha"
    elif echo "$amostra" | grep -E -qi '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}:'; then
        echo "formato_email_senha"
    elif echo "$amostra" | grep -qi 'USER:' && echo "$amostra" | grep -qi 'PASS:'; then
        echo "formato_bloco_user_pass"
    else
        echo "formato_desconhecido"
    fi
}


# Trata arquivos com formato URL:EMAIL:SENHA
# Trata arquivos com formato URL:EMAIL:SENHA
tratar_url_email_senha() {
    local arquivo="$1"
    local termo="$2"
    local diretorio="$3"
    local modulo="url_email_senha"  # Identificador do módulo

    local resultado
    resultado=$(grep -a -I -n "$termo" "$arquivo" 2>/dev/null)

    if [[ -n "$resultado" ]]; then
        echo "$resultado" >> "$diretorio/result_search.txt"

        while IFS= read -r linha; do
            # Extrai email usando regex
            if [[ $linha =~ ([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}) ]]; then
                email="${BASH_REMATCH[1]}"
                echo "$email (origem: $modulo)" >> "$diretorio/user_list.txt"  # Adiciona a origem
                echo "$email (origem: $modulo)" >> "$diretorio/user_list_${modulo}.txt" # Salva em arquivo específico do módulo

                # Remove o email da linha para obter a senha
                senha=$(echo "$linha" | sed "s/$email://")
                if [[ -n "$senha" ]]; then
                    echo "$senha (origem: $modulo)" >> "$diretorio/pass_list.txt"  # Adiciona a origem
                    echo "$senha (origem: $modulo)" >> "$diretorio/pass_list_${modulo}.txt" # Salva em arquivo específico do módulo
                fi
            fi
        done <<< "$resultado"
    fi
}

# Trata arquivos com formato EMAIL:SENHA
tratar_email_senha() {
    local arquivo="$1"
    local termo="$2"
    local diretorio="$3"
    local modulo="email_senha"  # Identificador do módulo

    local resultado
    resultado=$(grep -a -I -n "$termo" "$arquivo" 2>/dev/null)

    if [[ -n "$resultado" ]]; then
        echo "$resultado" >> "$diretorio/result_search.txt"

        while IFS= read -r linha; do
            linha=$(echo "$linha" | tr -d '\r')  # Normaliza \r\n → \n
            email="${linha%%:*}"
            senha="${linha#*:}"

            if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "$email (origem: $modulo)" >> "$diretorio/user_list.txt"  # Adiciona a origem
                echo "$email (origem: $modulo)" >> "$diretorio/user_list_${modulo}.txt" # Salva em arquivo específico do módulo
            fi

            if [[ -n "$senha" && ${#senha} -le 16 ]]; then
                echo "$senha (origem: $modulo)" >> "$diretorio/pass_list.txt"  # Adiciona a origem
                echo "$senha (origem: $modulo)" >> "$diretorio/pass_list_${modulo}.txt" # Salva em arquivo específico do módulo
            fi
        done <<< "$resultado"

        # Deduplicação com arquivos temporários
        sort -u "$diretorio/user_list.txt" > "$diretorio/user_list.tmp" && mv "$diretorio/user_list.tmp" "$diretorio/user_list.txt"
        sort -u "$diretorio/pass_list.txt" > "$diretorio/pass_list.tmp" && mv "$diretorio/pass_list.tmp" "$diretorio/pass_list.txt"
        sort -u "$diretorio/result_search.txt" > "$diretorio/result_search.tmp" && mv "$diretorio/result_search.tmp" "$diretorio/result_search.txt"
    fi
}

# Trata arquivos com blocos USER:\nPASS:
tratar_blocos_user_pass() {
    local arquivo="$1"
    local termo="$2"
    local diretorio="$3"
    local modulo="blocos_user_pass"  # Identificador do módulo

    local bloco=""
    local encontrou_termo=0

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ -z "$line" ]]; then
            bloco=""
            encontrou_termo=0
        else
            if echo "$line" | grep -iq "^USER:"; then
                user=$(echo "$line" | sed 's/^USER: //')
                echo "$user (origem: $modulo)" >> "$diretorio/user_list.txt"  # Adiciona a origem
                echo "$user (origem: $modulo)" >> "$diretorio/user_list_${modulo}.txt" # Salva em arquivo específico do módulo
            elif echo "$line" | grep -iq "^PASS:"; then
                pass=$(echo "$line" | sed 's/^PASS: //')
                echo "$pass (origem: $modulo)" >> "$diretorio/pass_list.txt"  # Adiciona a origem
                echo "$pass (origem: $modulo)" >> "$diretorio/pass_list_${modulo}.txt" # Salva em arquivo específico do módulo
            fi

            if echo "$line" | grep -iq "$termo"; then
                encontrou_termo=1
            fi
        fi
    done < "$arquivo"

    # Deduplicação
    sort -u -o "$diretorio/user_list.txt" "$diretorio/user_list.txt"
    sort -u -o "$diretorio/pass_list.txt" "$diretorio/pass_list.txt"
}

# Função para contar arquivos de forma segura
contar_arquivos() {
    local count=0
    shopt -s nullglob
    for file in *.txt; do
        [ -f "$file" ] && ((count++))
    done
    shopt -u nullglob
    echo "$count"
}


# Função para contar arquivos válidos
contar_arquivos_validos() {
    local count=0
    shopt -s nullglob
    for file in *.txt; do
        [ -f "$file" ] || continue
        if verificar_arquivo "$file"; then
            ((count++))
        fi
    done
    shopt -u nullglob
}

# Função para detectar e deletar arquivos binários
#deletar_binarios() {
#    local diretorio="$1"
#    > "$diretorio/binarios_deletados.txt"
#    shopt -s nullglob
#
#    for file in *.txt; do
#        [ -f "$file" ] || continue
#
#        if file "$file" | grep -q "text" && ! grep -q $'\x00' "$file" 2>/dev/null; then
#            continue
#        else
#            echo "$file" >> "$diretorio/binarios_deletados.txt"
#            if [ -w "$file" ]; then
#                rm -f "$file"
#            else
#                echo "[!] Falha ao remover: $file (sem permissão)" >> "$diretorio/binarios_deletados.txt"
#            fi
#        fi
#    done
#
#    shopt -u nullglob
#}


# Função para verificar se arquivo é válido
verificar_arquivo() {
    local arquivo="$1"
    [ -f "$arquivo" ] || return 1

    # Verifica se é um arquivo de texto ou se contém caracteres nulos
    if file --mime-type -b "$arquivo" | grep -q "text/plain" && ! grep -q $'\x00' "$arquivo" 2>/dev/null; then
        return 0
    fi
    return 1
}


# Função para criar barra de progresso
mostrar_progresso() {
    local atual=$1
    local total=$2
    local largura=50

    # Evita divisão por zero
    ((total == 0)) && total=1

    local preenchido=$((atual * largura / total))
    local vazio=$((largura - preenchido))
    local percentual=$((100 * atual / total))

    # Cores ANSI
    local cor_verde="\e[42m \e[0m"  # bloco verde
    local cor_cinza="\e[100m \e[0m" # bloco vazio cinza

    printf "\r["
    
    for ((i = 0; i < preenchido; i++)); do
        printf "${cor_verde}"
    done
    for ((i = 0; i < vazio; i++)); do
        printf "${cor_cinza}"
    done

    printf "] %3d%% (%d/%d)" "$percentual" "$atual" "$total"
    # Adiciona um pequeno atraso para visualização
    sleep 0.1
}

# Main
main() {
    exibir_banner

    read -rp "Informe o termo para busca: " termo
    if [[ -z "$termo" ]]; then
        echo "Erro: Nenhum termo informado."
        exit 1
    fi

    diretorio="$PWD/${termo// /_}"
    sudo mkdir -p "$diretorio"
    sudo chown -R $USER:$USER "$diretorio"
    sudo chmod -R 777 "$diretorio"
    
    : > "$diretorio/user_list.txt"
    : > "$diretorio/pass_list.txt"
    : > "$diretorio/result_search.txt"
    : > "$diretorio/resultadoGeral.txt"
    : > "$diretorio/Desconhecido.txt"

#    deletar_binarios "$PWD"  # sem &, evita race condition

    total_arquivos=$(contar_arquivos)
    if (( total_arquivos == 0 )); then
        echo "Nenhum arquivo .txt encontrado."
        exit 1
    fi

    arquivos_processados=0
    arquivos_validos=0

    shopt -s nullglob
    for file in *.txt; do
        ((arquivos_processados++))
        if verificar_arquivo "$file"; then
            ((arquivos_validos++))
            tipo=$(detectar_formato_arquivo "$file")
            case "$tipo" in
                formato_url_email_senha)  
                    tratar_url_email_senha "$file" "$termo" "$diretorio" ;;
                formato_email_senha)      
                    tratar_email_senha "$file" "$termo" "$diretorio" ;;
                formato_bloco_user_pass)  
                    tratar_blocos_user_pass "$file" "$termo" "$diretorio" ;;
                *)                        
                    echo "$file" >> "$diretorio/Desconhecido.txt" ;;
            esac
        fi

        mostrar_progresso "$arquivos_processados" "$total_arquivos"
    done
    shopt -u nullglob

    echo -e "\n"
    echo "✔️  Busca finalizada. Resultados em: $diretorio"
    echo " - Arquivos processados: $arquivos_processados"
    echo " - Arquivos válidos:     $arquivos_validos"
    echo " - Usuários:             $(wc -l < "$diretorio/user_list.txt") encontrados"
    echo " - Senhas:               $(wc -l < "$diretorio/pass_list.txt") encontradas"
}

main

#┌────────────────────────────┐
#│ Início (main)              │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ exibir_banner              │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ Solicita termo de busca    │◄────────────────────┐
#│ (read -rp ...)             │                     │
#└────────────┬───────────────┘                     │
#             │                                     │
#         [termo vazio?]───────Sim─────────────┐    │
#             │                                │    │
#            Não                               ▼    │
#             │                        ┌─────────────────────┐
#             ▼                        │ Exibe erro e sai     │
#┌────────────────────────────┐       └─────────────────────┘
#│ Cria diretório de saída    │
#│ e zera arquivos            │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ deletar_binarios "$PWD"    │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ Conta arquivos `.txt`      │
#│ total_arquivos             │
#└────────────┬───────────────┘
#             │
#      [total = 0?]───Sim───────┐
#             │                ▼
#            Não       ┌─────────────────────┐
#             │        │ Exibe aviso e sai   │
#             ▼        └─────────────────────┘
#┌────────────────────────────┐
#│ Loop: para cada `.txt`     │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ arquivos_processados++     │
#└────────────┬───────────────┘
#             │
#     [arquivo válido?]─────Não─────────────┐
#             │                             │
#            Sim                            │
#             │                             ▼
#             ▼                     (Pula para próximo)
#┌────────────────────────────┐
#│ arquivos_validos++         │
#│ detectar_formato_arquivo   │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ case tipo de formato       │
#│   - URL:EMAIL:SENHA        │
#│   - EMAIL:SENHA            │
#│   - USER:PASS              │
#│   - Outro = desconhecido   │
#└────────────┬───────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ mostrar_progresso()        │
#└────────────┬───────────────┘
#             │
#             ▼
#       (Repete o loop)
#             │
#             ▼
#      Após fim do loop
#             │
#             ▼
#┌────────────────────────────┐
#│ Exibe resumo final         │
#└────────────────────────────┘
#             │
#             ▼
#┌────────────────────────────┐
#│ Fim                        │
#└────────────────────────────┘
