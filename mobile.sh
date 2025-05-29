BURP_URL="https://portswigger.net/burp/releases/download?product=community&version=2023.4.1&type=Jar"
BURP_DIR="$HOME/BurpSuite"
BURP_JAR="$BURP_DIR/burpsuite_community.jar"
LAUNCHER="$HOME/.local/bin/burpsuite"

GENYMOTION_VERSION="3.4.3"
GENYMOTION_BIN="genymotion-${GENYMOTION_VERSION}-linux_x64.bin"
DOWNLOAD_URL="https://dl.genymotion.com/releases/genymotion-${GENYMOTION_VERSION}/${GENYMOTION_BIN}"
INSTALL_DIR="/opt/genymotion"

APKTOOL_DIR="/opt/apktool"
BIN_LINK="/usr/local/bin/apktool"

DEX2JAR_DIR="/opt/dex2jar"
BIN_LINK="/usr/local/bin/d2j-dex2jar.sh"
REPO_URL="https://github.com/pxb1988/dex2jar"

JDGUI_DIR="/opt/jd-gui"
BIN_LINK="/usr/local/bin/jd-gui"

JADX_DIR="/opt/jadx"
BIN_CLI="/usr/local/bin/jadx"
BIN_GUI="/usr/local/bin/jadx-gui"

MOBSF_IMAGE="opensecurity/mobile-security-framework-mobsf:latest"
PORT=8000

GHIDRA_INSTALL_DIR="/opt/ghidra"
GHIDRA_BIN_LINK="/usr/local/bin/ghidraRun"
GHIDRA_DOWNLOAD_URL="https://github.com/NationalSecurityAgency/ghidra/releases/latest/download/ghidra_10.4_PUBLIC_20230524.zip"


############

# Funções do mobsf

function msg() {
    echo -e "\033[1;34m[*]\033[0m $1"
}

function err() {
    echo -e "\033[1;31m❌\033[0m $1"
}

function ok() {
    echo -e "\033[1;32m✅\033[0m $1"
}

############

verificar_adb() {
    if command -v adb &>/dev/null; then
        echo "✅ ADB encontrado em: $(command -v adb)"
        echo "✅ ADB está instalado no sistema."
        return 0
    else
        echo "❌ ADB NÃO encontrado."
        echo "❌ ADB NÃO está instalado no sistema."
        return 1
    fi
}

verificar_docker() {
    if ! command -v docker &>/dev/null; then
        echo "❌ Docker NÃO encontrado."
        echo "❌ Docker NÃO está instalado no sistema."
        return 1
    fi

    echo "✅ Docker encontrado em: $(command -v docker)"

    # Verifica se o serviço Docker está ativo
    if systemctl is-active --quiet docker; then
        echo "✅ Serviço Docker está em execução."
        return 0
    else
        echo "⚠️ Serviço Docker não está rodando. Tentando iniciar..."

        # Tenta iniciar o serviço Docker (requer sudo)
        sudo systemctl start docker

        sleep 2

        if systemctl is-active --quiet docker; then
            echo "✅ Serviço Docker iniciado com sucesso."
        else
            echo "❌ Falha ao iniciar o serviço Docker."
        fi
    fi
}

verificar_frida() {
    local found=0

    if command -v frida &>/dev/null; then
        echo "✅ 'frida' encontrado em: $(command -v frida)"
        found=1
    else
        echo "❌ 'frida' NÃO encontrado."
    fi

    if command -v frida-server &>/dev/null; then
        echo "✅ 'frida-server' encontrado em: $(command -v frida-server)"
        found=1
    else
        echo "❌ 'frida-server' NÃO encontrado."
    fi

    if command -v frida-ps &>/dev/null; then
        echo "✅ 'frida-ps' encontrado em: $(command -v frida-ps)"
        found=1
    else
        echo "❌ 'frida-ps' NÃO encontrado."
    fi

    if [[ $found -eq 1 ]]; then
        echo "✅ Frida está instalado no sistema."
        return 0
    else
        echo "❌ Frida NÃO está instalado no sistema."
        return 1
    fi
}

verificar_objection() {
    if ! command -v objection &>/dev/null; then
        echo "❌ Objection NÃO encontrado no PATH."
        return 1
    fi

    echo "✅ Objection encontrado: $(command -v objection)"

    echo "✅ Verificação concluída."
    return 0
}

verificar_burp() {

    # Verifica se existe o comando no PATH
    if command -v burpsuite &>/dev/null; then
        echo "✅ Burp Suite encontrado no PATH: $(command -v burpsuite)"
        return 0
    fi

    # Verifica se a variável BURP_JAR está definida e existe
    if [[ -n "$BURP_JAR" ]] && [[ -f "$BURP_JAR" ]]; then
        echo "✅ Burp Suite encontrado via arquivo JAR em: $BURP_JAR"
        return 0
    fi

    # Procura automaticamente o arquivo .jar em locais comuns
    BURP_JAR_AUTO=$(find ~/ /opt /usr/local -iname "burp*.jar" 2>/dev/null | head -n1)

    if [[ -n "$BURP_JAR_AUTO" ]]; then
        echo "✅ Burp Suite encontrado via arquivo JAR em: $BURP_JAR_AUTO"
        return 0
    fi

    echo "❌ Burp Suite NÃO encontrado na máquina."
    return 1
}


verificar_genymotion() {
    local found=0

    if command -v genymotion &>/dev/null; then
        echo "✅ 'genymotion' encontrado em: $(command -v genymotion)"
        found=1
    else
        echo "❌ 'genymotion' NÃO encontrado no PATH."
    fi

    local default_path="/opt/genymotion"
    if [[ -d "$default_path" ]]; then
        echo "✅ Diretório padrão do Genymotion encontrado: $default_path"
        found=1
    else
        echo "❌ Diretório padrão do Genymotion NÃO encontrado: $default_path"
    fi

    if command -v VBoxManage &>/dev/null; then
        echo "✅ VirtualBox encontrado em: $(command -v VBoxManage)"
    else
        echo "❌ VirtualBox NÃO encontrado."
    fi

    if (( found )); then
        echo "✅ Genymotion está instalado no sistema."
        return 0
    else
        echo "❌ Genymotion NÃO está instalado no sistema."
        return 1
    fi
}

verificar_drozer() {

    if command -v drozer &>/dev/null; then
        echo "✅ Drozer encontrado no PATH: $(command -v drozer)"
        return 0
    fi

    for dir in /usr/local/bin /usr/bin "$HOME/drozer"; do
        if [[ -x "$dir/drozer" ]]; then
            echo "✅ Drozer encontrado no diretório: $dir"
            return 0
        fi
    done

    echo "❌ Drozer NÃO encontrado na máquina."
    return 1
}

verificar_apktool() {

    if command -v apktool &>/dev/null; then
        echo "✅ APKTool encontrado no PATH: $(command -v apktool)"
        return 0
    fi

    APKTOOL_PATH=$(sudo find / -type f \( -iname "apktool" -o -iname "apktool.jar" \) 2>/dev/null | head -n 1 || true)

    if [[ -n "$APKTOOL_PATH" ]]; then
        echo "✅ APKTool encontrado em: $APKTOOL_PATH"
        return 0
    else
        echo "❌ APKTool NÃO encontrado na máquina."
        return 1
    fi
}

verificar_dex2jar() {

    # Verifica se o binário d2j-dex2jar.sh está no PATH
    if command -v d2j-dex2jar.sh &>/dev/null; then
        echo "✅ Dex2Jar encontrado no PATH: $(command -v d2j-dex2jar.sh)"
        return 0
    fi

    # Verifica se há pastas Dex2Jar no sistema
    DEX2JAR_PATH=$(sudo find / -type f -name "d2j-dex2jar.sh" 2>/dev/null | head -n 1)

    if [[ -n "$DEX2JAR_PATH" ]]; then
        echo "✅ Dex2Jar encontrado em: $DEX2JAR_PATH"
        return 0
    else
        echo "❌ Dex2Jar NÃO encontrado na máquina."
        return 1
    fi
}

verificar_jdgui() {

    if command -v jd-gui &>/dev/null; then
        echo -e "✅ JD-GUI encontrado no PATH: $(command -v jd-gui)"
        return 0
    fi

    JDGUI_PATH=$(sudo find / -type f \( -iname "jd-gui" -o -iname "jd-gui.jar" -o -iname "jd-gui.exe" \) 2>/dev/null | head -n 1)

    if [[ -n "$JDGUI_PATH" ]]; then
        echo -e "✅ JD-GUI encontrado em: $JDGUI_PATH"
        return 0
    else
        echo -e "❌ JD-GUI NÃO encontrado."
        return 1
    fi
}

verificar_jadx() {

    if command -v jadx &>/dev/null; then
        echo "✅ JADX CLI encontrado no PATH: $(command -v jadx)"
        return 0
    fi

    if command -v jadx-gui &>/dev/null; then
        echo "✅ JADX GUI encontrado no PATH: $(command -v jadx-gui)"
        return 0
    fi

    JADX_PATH=$(sudo find / -type f \( -iname "jadx" -o -iname "jadx-gui" -o -iname "jadx*.jar" \) 2>/dev/null | head -n 1)

    if [[ -n "$JADX_PATH" ]]; then
        echo "✅ JADX encontrado em: $JADX_PATH"
        return 0
    else
        echo "❌ JADX NÃO encontrado na máquina."
        return 1
    fi
}

verificar_mobsf() {
    local status=0

    local MOBSF_PATH
    MOBSF_PATH=$(sudo find /opt /usr/local "$HOME" -type f -name "run.sh" 2>/dev/null | grep "Mobile-Security-Framework-MobSF" | head -n1)

    if [[ -n "$MOBSF_PATH" ]]; then
        echo "✅ MobSF encontrado no caminho: $(dirname "$MOBSF_PATH")"
    else
        echo "❌ MobSF (nativo) não encontrado na máquina."
        status=1
    fi

    if ! command -v docker &>/dev/null; then
        echo "❌ Docker não instalado."
        status=1
    else
        if docker ps &>/dev/null; then
            echo "✅ Permissão Docker OK sem sudo."
        elif sudo docker ps &>/dev/null; then
            echo "✅ Permissão Docker OK com sudo."
        else
            echo "❌ Sem permissão para usar Docker (nem com sudo)."
            status=1
        fi
    fi

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -iq 'mobsf'; then
        echo "✅ Imagem Docker MobSF encontrada."
    else
        echo "❌ Imagem Docker MobSF não encontrada."
        status=1
    fi

    return $status
}

verificar_ghidra() {

    if command -v ghidraRun &>/dev/null; then
        echo "✅ Ghidra encontrado no PATH: $(command -v ghidraRun)"
        return 0
    fi

    # Verifica diretórios comuns de instalação
    for dir in /opt/ghidra "$HOME/ghidra" "/usr/local/ghidra"; do
        if [[ -x "$dir/ghidraRun" ]]; then
            echo "✅ Ghidra encontrado no diretório: $dir"
            return 0
        fi
    done

    echo "❌ Ghidra NÃO encontrado na máquina."
    return 1
}

verificar_android_studio() {
    local executavel="studio.sh"
    local resultado_encontrado=1


    # Verificar no PATH
    if command -v "$executavel" &>/dev/null; then
        echo "✅ Android Studio encontrado no PATH como '$executavel'"
        resultado_encontrado=0
    fi

    # Verificar diretórios padrão
    if [[ $resultado_encontrado -ne 0 ]]; then
        local paths=(
            "$HOME/android-studio"
            "/opt/android-studio"
            "/usr/local/android-studio"
            "/usr/android-studio"
        )

        for path in "${paths[@]}"; do
            if [[ -d "$path" ]]; then
                echo "✅ Android Studio encontrado na pasta: $path"
                resultado_encontrado=0
                break
            fi

            if [[ -f "$path/bin/$executavel" ]]; then
                echo "✅ Android Studio encontrado no executável: $path/bin/$executavel"
                resultado_encontrado=0
                break
            fi
        done
    fi
    
    if [[ $resultado_encontrado -ne 0 ]]; then
        if [[ $EUID -ne 0 ]]; then
            read -rp "[?] Android Studio não encontrado em locais comuns. Deseja buscar no sistema inteiro? Isso pode demorar e requer permissões de administrador (sudo) [s/N]: " resposta
            if [[ "$resposta" =~ ^[Ss]$ ]]; then
                echo "[*] Buscando com sudo... aguarde"
                resultados=$(sudo find / -type f -iname "$executavel" 2>/dev/null || true)
                if [[ -n "$resultados" ]]; then
                    echo "✅ Android Studio encontrado nos seguintes locais:"
                    echo "$resultados"
                    resultado_encontrado=0
                else
                    echo "❌ Android Studio não encontrado no sistema."
                fi
            else
                echo "❌ Busca no sistema inteiro cancelada pelo usuário."
            fi
        else
            echo "[*] Buscando no sistema inteiro... (isso pode demorar)"
            resultados=$(find / -type f -iname "$executavel" 2>/dev/null || true)
            if [[ -n "$resultados" ]]; then
                echo "✅ Android Studio encontrado nos seguintes locais:"
                echo "$resultados"
                resultado_encontrado=0
            else
                echo "❌ Android Studio não encontrado no sistema."
            fi
        fi
    fi

}


#############################################################


instalar_adb() {
    echo "[*] Detectando gerenciador de pacotes..."

    if command -v apt &>/dev/null; then
        echo "[*] Usando apt para instalar adb..."
        sudo apt update
        sudo apt install -y adb
    elif command -v dnf &>/dev/null; then
        echo "[*] Usando dnf para instalar adb..."
        sudo dnf install -y android-tools
    elif command -v yum &>/dev/null; then
        echo "[*] Usando yum para instalar adb..."
        sudo yum install -y android-tools
    else
        echo "[-] Gerenciador de pacotes não suportado automaticamente."
        echo "Instale o ADB manualmente."
        return 1
    fi

    # Verifica se instalou corretamente
    if command -v adb &>/dev/null; then
        echo "[✔] ADB instalado com sucesso!"
        return 0
    else
        echo "[-] Falha na instalação do ADB."
        return 1
    fi
}

instalar_docker() {
    echo "[*] Detectando sistema e gerenciador de pacotes..."

    if command -v apt &>/dev/null; then
        echo "[*] Sistema baseado em Debian/Ubuntu detectado."

        # Atualiza e instala dependências
        sudo apt update
        sudo apt install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Adiciona chave oficial Docker
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Configura o repositório Docker
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update

        # Instala o Docker Engine
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    elif command -v yum &>/dev/null; then
        echo "[*] Sistema baseado em CentOS/Fedora detectado."

        sudo yum install -y yum-utils

        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        echo "[-] Gerenciador de pacotes não suportado automaticamente."
        echo "Instale o Docker manualmente."
        return 1
    fi

    echo "[*] Ativando e iniciando o serviço Docker..."

    sudo systemctl enable docker
    sudo systemctl start docker

    sleep 3

    # Verifica status do Docker
    if command -v docker &>/dev/null && systemctl is-active --quiet docker; then
        echo "[✔] Docker instalado e serviço iniciado com sucesso!"
        return 0
    else
        echo "[-] Falha na instalação ou inicialização do Docker."
        return 1
    fi
}

instalar_frida() {
    echo "[*] Verificando pré-requisitos..."

    # Verifica se python3 está instalado
    if ! command -v python3 &>/dev/null; then
        echo "[-] Python3 não encontrado. Por favor, instale o Python3 primeiro."
        return 1
    fi

    # Verifica se pip está instalado
    if ! command -v pip3 &>/dev/null; then
        echo "[*] pip3 não encontrado, tentando instalar..."

        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y python3-pip
        elif command -v yum &>/dev/null; then
            sudo yum install -y python3-pip
        else
            echo "[-] Gerenciador de pacotes não suportado para instalar pip3 automaticamente."
            return 1
        fi

        if ! command -v pip3 &>/dev/null; then
            echo "[-] Falha ao instalar pip3."
            return 1
        fi
    fi

    echo "[*] Instalando Frida via pip..."

    # Instala ou atualiza frida
    pip3 install --user --upgrade frida-tools

    if [[ $? -eq 0 ]]; then
        echo "[✔] Frida instalado com sucesso!"
        echo "[ℹ] Certifique-se que ~/.local/bin está no seu PATH para acessar os comandos."
        return 0
    else
        echo "[-] Falha na instalação do Frida."
        return 1
    fi
}

instalar_objection() {
    echo "[*] Instalando dependências do Objection..."

    if ! command -v python3 &>/dev/null; then
        echo "[*] Python3 não encontrado. Instalando..."
        sudo apt update
        sudo apt install -y python3
    fi

    if ! command -v pip3 &>/dev/null; then
        echo "[*] pip3 não encontrado. Instalando..."
        sudo apt install -y python3-pip
    fi

    python3 -m pip install --upgrade pip setuptools wheel

    echo "[*] Instalando Frida (dependência do Objection)..."
    python3 -m pip install --upgrade frida

    echo "[*] Instalando Objection..."
    python3 -m pip install --upgrade objection

    if ! command -v objection &>/dev/null; then
        OBJECTION_PATH=$(python3 -m site --user-base)/bin/objection
        if [[ -f "$OBJECTION_PATH" ]]; then
            sudo ln -sf "$OBJECTION_PATH" /usr/local/bin/objection
        fi
    fi

    echo "[+] Instalação concluída!"
    echo "[+] Teste com: objection --help"
}

instalar_burp() {
    echo "[*] Burp Suite não encontrado. Iniciando instalação..."

    mkdir -p "$BURP_DIR"
    mkdir -p "$(dirname "$LAUNCHER")"

    echo "[*] Baixando Burp Suite Community Edition..."
    curl -L -o "$BURP_JAR" "$BURP_URL"
    if [ $? -ne 0 ]; then
        echo "[-] Falha no download do Burp Suite. Abortando."
        exit 1
    fi

    echo "[*] Criando launcher para facilitar execução..."
    cat > "$LAUNCHER" << EOF
#!/bin/bash
java -jar "$BURP_JAR" "\$@"
EOF

    chmod +x "$LAUNCHER"

    echo "[✔] Burp Suite instalado com sucesso!"
    echo "[ℹ] Use o comando 'burpsuite' para iniciar."
}

instalar_genymotion() {
    echo "[*] Verificando pré-requisitos..."

    if ! command -v VBoxManage &>/dev/null; then
        echo "[-] VirtualBox não encontrado. Instale o VirtualBox antes de continuar."
        return 1
    fi

    if [[ -d "$INSTALL_DIR" ]]; then
        echo "[!] Genymotion já instalado em $INSTALL_DIR"
        return 0
    fi

    echo "[*] Baixando Genymotion..."

    # Preferir curl com flags seguras e verificar erro
    if ! curl -L -o "$GENYMOTION_BIN" "$DOWNLOAD_URL"; then
        echo "[-] Falha no download do instalador."
        return 1
    fi

    chmod +x "$GENYMOTION_BIN"

    echo "[*] Executando instalador..."

    if ! sudo ./"$GENYMOTION_BIN" --target "$INSTALL_DIR"; then
        echo "[-] Falha na instalação do Genymotion."
        rm -f "$GENYMOTION_BIN"
        return 1
    fi

    rm -f "$GENYMOTION_BIN"

    echo "[✔] Genymotion instalado com sucesso em $INSTALL_DIR"
    echo "[*] Adicione '$INSTALL_DIR/bin' ao PATH para executar o Genymotion."

    return 0
}

instalar_drozer() {
    echo "[*] Instalando dependências..."

    # Detecta sistema baseado em Debian (apt) ou RedHat (yum)
    if command -v apt &>/dev/null; then
        sudo apt update
        # python2 e pip2 podem estar descontinuados em algumas distros recentes
        sudo apt install -y python2 python2-pip git || {
            echo "[-] Falha ao instalar dependências com apt."
            exit 1
        }
    elif command -v yum &>/dev/null; then
        sudo yum install -y python2 python2-pip git || {
            echo "[-] Falha ao instalar dependências com yum."
            exit 1
        }
    else
        echo "[-] Gerenciador de pacotes não suportado. Instale python2, pip2 e git manualmente."
        exit 1
    fi

    echo "[*] Clonando repositório drozer..."
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/ReversecLabs/drozer.git "$TEMP_DIR/drozer" || {
        echo "[-] Falha ao clonar repositório drozer."
        rm -rf "$TEMP_DIR"
        exit 1
    }

    cd "$TEMP_DIR/drozer" || { echo "[-] Diretório não encontrado."; rm -rf "$TEMP_DIR"; exit 1; }

    echo "[*] Instalando drozer..."
    sudo python2 setup.py install || {
        echo "[-] Falha na instalação do drozer."
        rm -rf "$TEMP_DIR"
        exit 1
    }

    # Garante link simbólico caso necessário
    if ! command -v drozer &>/dev/null; then
        sudo ln -sf /usr/local/bin/drozer /usr/bin/drozer
    fi

    echo "[+] Drozer instalado com sucesso!"
    rm -rf "$TEMP_DIR"
}

instalar_apktool() {
    echo "[*] Instalando APKTool..."

    # Detectar gerenciador de pacotes e instalar dependências
    if ! command -v wget &>/dev/null; then
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y wget
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y wget
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm wget
        else
            echo "[-] Gerenciador de pacotes não suportado para instalar wget."
            exit 1
        fi
    fi

    if ! command -v java &>/dev/null; then
        if command -v apt &>/dev/null; then
            sudo apt install -y default-jre
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y java-latest-openjdk
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm jre-openjdk
        else
            echo "[-] Gerenciador de pacotes não suportado para instalar Java."
            exit 1
        fi
    fi

    if [[ -d "$APKTOOL_DIR" ]]; then
        read -rp "[!] Diretório $APKTOOL_DIR existe. Deseja removê-lo para nova instalação? [s/N]: " resp
        if [[ ! "$resp" =~ ^[Ss]$ ]]; then
            echo "[-] Instalação cancelada pelo usuário."
            exit 1
        fi
        sudo rm -rf "$APKTOOL_DIR"
    fi

    sudo mkdir -p "$APKTOOL_DIR"
    cd /tmp || exit 1

    echo "[*] Buscando última versão do APKTool..."

    JAR_URL=$(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest \
        | grep "browser_download_url" \
        | grep "apktool_[0-9].*\.jar" \
        | cut -d '"' -f 4)

    SCRIPT_URL=$(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest \
        | grep "browser_download_url" \
        | grep "/apktool$" \
        | cut -d '"' -f 4)

    if [[ -z "$JAR_URL" || -z "$SCRIPT_URL" ]]; then
        echo "[-] Não foi possível localizar a última versão do APKTool."
        exit 1
    fi

    echo "[*] Baixando APKTool..."
    wget -q --show-progress "$JAR_URL" -O apktool.jar
    wget -q --show-progress "$SCRIPT_URL" -O apktool

    sudo mv apktool.jar "$APKTOOL_DIR/"
    sudo mv apktool "$APKTOOL_DIR/"
    sudo chmod +x "$APKTOOL_DIR/apktool"

    echo "[*] Criando link simbólico no $BIN_LINK..."
    sudo tee "$BIN_LINK" >/dev/null <<EOF
#!/bin/bash
java -jar $APKTOOL_DIR/apktool.jar "\$@"
EOF

    sudo chmod +x "$BIN_LINK"

    echo "[+] APKTool instalado com sucesso!"
    echo "[+] Execute com: apktool"
}

instalar_dex2jar() {
    echo "[*] Instalando Dex2Jar..."

    # Verifica dependências
    if ! command -v wget &>/dev/null; then
        echo "[*] Instalando wget..."
        sudo apt update
        sudo apt install -y wget
    fi

    if ! command -v unzip &>/dev/null; then
        echo "[*] Instalando unzip..."
        sudo apt install -y unzip
    fi

    # Cria pasta de instalação
    sudo rm -rf "$DEX2JAR_DIR"
    sudo mkdir -p "$DEX2JAR_DIR"
    cd /tmp || exit

    # Baixa a release mais recente
    echo "[*] Baixando Dex2Jar..."
    LATEST_URL=$(curl -s https://api.github.com/repos/pxb1988/dex2jar/releases/latest \
        | grep "browser_download_url" \
        | grep ".zip" \
        | cut -d '"' -f 4)

    if [[ -z "$LATEST_URL" ]]; then
        echo "[-] Não foi possível localizar a versão mais recente do Dex2Jar."
        exit 1
    fi

    wget "$LATEST_URL" -O dex2jar.zip

    echo "[*] Extraindo..."
    unzip dex2jar.zip -d dex2jar-temp
    sudo mv dex2jar-temp/*/* "$DEX2JAR_DIR"

    # Cria link simbólico
    echo "[*] Criando link simbólico..."
    sudo ln -sf "$DEX2JAR_DIR/d2j-dex2jar.sh" "$BIN_LINK"

    # Permissão de execução
    sudo chmod +x "$BIN_LINK"
    sudo chmod +x "$DEX2JAR_DIR/"*.sh

    echo "[+] Dex2Jar instalado com sucesso!"
    echo "[+] Teste executando: d2j-dex2jar.sh --help"
}

instalar_jdgui() {
    echo "[*] Instalando JD-GUI..."

    # Verifica dependências
    if ! command -v wget &>/dev/null; then
        echo "[*] Instalando wget..."
        sudo apt update && sudo apt install -y wget || { echo "Falha ao instalar wget"; exit 1; }
    fi

    if ! command -v java &>/dev/null; then
        echo "[*] Java não encontrado. Instalando OpenJDK..."
        sudo apt install -y default-jre || { echo "Falha ao instalar Java"; exit 1; }
    fi

    sudo rm -rf "$JDGUI_DIR"
    sudo mkdir -p "$JDGUI_DIR"

    echo "[*] Buscando última versão do JD-GUI..."
    LATEST_URL=$(curl -s https://api.github.com/repos/java-decompiler/jd-gui/releases/latest \
        | grep "browser_download_url" \
        | grep ".jar" \
        | cut -d '"' -f 4)

    if [[ -z "$LATEST_URL" ]]; then
        echo -e "\033[1;31m[-]\033[0m Não foi possível encontrar a última versão do JD-GUI."
        exit 1
    fi

    FILE_NAME=$(basename "$LATEST_URL")

    echo "[*] Baixando $FILE_NAME ..."
    wget -q --show-progress "$LATEST_URL" -O "/tmp/$FILE_NAME" || { echo "Falha ao baixar JD-GUI"; exit 1; }

    sudo mv "/tmp/$FILE_NAME" "$JDGUI_DIR/jd-gui.jar"

    echo "[*] Criando atalho executável..."
    echo -e '#!/bin/bash\njava -jar /opt/jd-gui/jd-gui.jar "$@"' | sudo tee "$BIN_LINK" >/dev/null
    sudo chmod +x "$BIN_LINK"

    echo -e "\033[1;32m[+]\033[0m JD-GUI instalado com sucesso!"
    echo -e "\033[1;32m[+]\033[0m Execute com: jd-gui"
}

instalar_jadx() {
    echo "[*] Iniciando instalação do JADX..."

    # Verificar e instalar dependências numa única atualização
    MISSING_DEPS=()
    for dep in wget unzip default-jre; do
        if ! command -v $dep &>/dev/null; then
            MISSING_DEPS+=($dep)
        fi
    done

    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        echo "[*] Instalando dependências: ${MISSING_DEPS[*]}"
        sudo apt update
        sudo apt install -y "${MISSING_DEPS[@]}"
    else
        echo "[+] Todas dependências necessárias já estão instaladas."
    fi

    sudo rm -rf "$JADX_DIR"
    sudo mkdir -p "$JADX_DIR"
    cd /tmp || exit

    echo "[*] Buscando última versão do JADX..."
    LATEST_URL=$(curl -s https://api.github.com/repos/skylot/jadx/releases/latest \
        | grep "browser_download_url" \
        | grep "jadx-bin.*zip" \
        | cut -d '"' -f 4)

    if [[ -z "$LATEST_URL" ]]; then
        echo "[-] Não foi possível localizar a última versão do JADX."
        exit 1
    fi

    FILE_NAME=$(basename "$LATEST_URL")
    echo "[*] Baixando $FILE_NAME..."
    wget "$LATEST_URL" -O "$FILE_NAME"

    echo "[*] Extraindo $FILE_NAME..."
    unzip -q "$FILE_NAME" -d jadx-temp

    # Mover arquivos para /opt/jadx
    sudo mv jadx-temp/*/* "$JADX_DIR"

    # Criar atalhos executáveis
    echo "[*] Criando atalhos executáveis..."

    sudo tee "$BIN_CLI" >/dev/null <<EOF
#!/bin/bash
"$JADX_DIR/bin/jadx" "\$@"
EOF

    sudo tee "$BIN_GUI" >/dev/null <<EOF
#!/bin/bash
"$JADX_DIR/bin/jadx-gui" "\$@"
EOF

    sudo chmod +x "$BIN_CLI" "$BIN_GUI"

    echo "[+] JADX instalado com sucesso!"
    echo "[+] Use: jadx <arquivo.apk> para CLI"
    echo "[+] Use: jadx-gui para interface gráfica"
}


instalar_mobsf(){

    pull_mobsf() {
        msg "Baixando imagem MobSF..."
        sudo docker pull "$MOBSF_IMAGE"
    }

    run_mobsf() {
        msg "Rodando MobSF no Docker na porta $PORT..."
        sudo docker run -d --rm -p "$PORT":8000 "$MOBSF_IMAGE"
        ok "MobSF rodando! Acesse http://127.0.0.1:$PORT"
    }
}

instalar_ghidra() {
    echo "[*] Instalando Ghidra..."

    # Verifica se wget ou curl estão instalados para download
    if ! command -v wget &>/dev/null && ! command -v curl &>/dev/null; then
        echo "[-] wget ou curl necessário para baixar arquivos. Instalando wget..."
        sudo apt update
        sudo apt install -y wget
    fi

    # Verifica se unzip está instalado
    if ! command -v unzip &>/dev/null; then
        echo "[*] unzip não encontrado. Instalando unzip..."
        sudo apt install -y unzip
    fi

    # Remove instalação antiga se existir
    if [[ -d "$GHIDRA_INSTALL_DIR" ]]; then
        echo "[*] Removendo instalação antiga em $GHIDRA_INSTALL_DIR"
        sudo rm -rf "$GHIDRA_INSTALL_DIR"
    fi

    sudo mkdir -p "$GHIDRA_INSTALL_DIR"
    cd /tmp || exit

    echo "[*] Baixando Ghidra..."
    if command -v wget &>/dev/null; then
        wget -O ghidra.zip "$GHIDRA_DOWNLOAD_URL"
    else
        curl -L -o ghidra.zip "$GHIDRA_DOWNLOAD_URL"
    fi

    echo "[*] Extraindo Ghidra..."
    unzip -q ghidra.zip -d /tmp

    # Encontra diretório extraído
    EXTRACTED_DIR=$(find /tmp -maxdepth 1 -type d -name "ghidra_*" | head -n 1)

    if [[ -z "$EXTRACTED_DIR" ]]; then
        echo "[-] Falha ao encontrar diretório extraído."
        exit 1
    fi

    echo "[*] Movendo Ghidra para $GHIDRA_INSTALL_DIR"
    sudo mv "$EXTRACTED_DIR"/* "$GHIDRA_INSTALL_DIR/"

    # Limpar arquivos temporários
    rm -rf /tmp/ghidra.zip "$EXTRACTED_DIR"

    # Criar link simbólico para facilitar execução
    echo "[*] Criando link simbólico para ghidraRun em $GHIDRA_BIN_LINK"
    sudo ln -sf "$GHIDRA_INSTALL_DIR/ghidraRun" "$GHIDRA_BIN_LINK"
    sudo chmod +x "$GHIDRA_INSTALL_DIR/ghidraRun"

    echo "[+] Ghidra instalado com sucesso!"
    echo "[+] Execute com: ghidraRun"
}


instalar_android_studio() {
    local URL_DOWNLOAD="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.3.2.15/android-studio-2024.3.2.15-linux.tar.gz"
    local DESTINO="/opt/android-studio"
    local ARQUIVO_TMP="/tmp/android-studio.tar.gz"

    echo "[*] Iniciando processo de instalação do Android Studio..."

    if [[ -d "$DESTINO" ]]; then
        echo "[!] Android Studio já está instalado em $DESTINO"
        return 0
    fi

    echo "[*] Instalando dependências..."
    if command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y curl tar lib32z1 lib32ncurses6 libbz2-1.0 lib32stdc++6
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y curl tar zlib ncurses-compat-libs glibc.i686 libstdc++.i686
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu --noconfirm curl tar zlib lib32-glibc lib32-gcc-libs
    else
        echo "[-] Gerenciador de pacotes não suportado. Instale manualmente as dependências."
    fi

    echo "[*] Baixando Android Studio..."
    if ! curl -Lo "$ARQUIVO_TMP" "$URL_DOWNLOAD"; then
        echo "[-] Falha no download. Verifique sua conexão ou URL."
        return 1
    fi

    echo "[*] Extraindo para $DESTINO..."
    sudo mkdir -p "$DESTINO"
    sudo tar -xzf "$ARQUIVO_TMP" -C /opt
    sudo mv /opt/android-studio* "$DESTINO"

    echo "[*] Criando link simbólico..."
    sudo ln -sf "$DESTINO/bin/studio.sh" /usr/local/bin/android-studio

    rm -f "$ARQUIVO_TMP"

    echo "[✔] Android Studio instalado com sucesso em $DESTINO"
    echo "[ℹ] Execute 'android-studio' no terminal para abrir."

    return 0
}

FERRAMENTAS=(
    adb docker frida objection burp genymotion drozer
    apktool dex2jar jdgui jadx mobsf ghidra android_studio
)

NAO_INSTALADOS=()

echo -e "\n🔍 Iniciando verificações de ferramentas...\n"

for ferramenta in "${FERRAMENTAS[@]}"; do
    if "verificar_${ferramenta}"; then
        echo "✅ ${ferramenta} está instalado."
    else
        echo "❌ ${ferramenta} NÃO encontrado."
        NAO_INSTALADOS+=("$ferramenta")
    fi
    echo "--------------------------------------------"
done

if [ ${#NAO_INSTALADOS[@]} -eq 0 ]; then
    echo -e "\n🎉 Todas as ferramentas estão instaladas."
else
    echo -e "\n⚙️ Iniciando instalação dos que faltam...\n"
    for ferramenta in "${NAO_INSTALADOS[@]}"; do
        echo "⚙️ Instalando ${ferramenta}..."
        "install_${ferramenta}"
        echo "--------------------------------------------"
    done
fi



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    verificar_adb
    verificar_docker
    verificar_frida
    verificar_objection
    verificar_burp
    verificar_genymotion
    verificar_drozer
    verificar_apktool
    verificar_dex2jar
    verificar_jdgui
    verificar_jadx
    verificar_mobsf
    verificar_ghidra
    verificar_android_studio
fi
