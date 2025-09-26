#!/usr/bin/env bash
set -e

echo "=== Instalando asdf (Linux/macOS) ==="

# Detecta SO
OS="$(uname -s)"
echo "Sistema detectado: $OS"

# Função para instalar dependências
install_dependencies() {
  if [[ "$OS" == "Darwin" ]]; then
    echo "Instalando dependências no macOS (via brew)..."
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew não encontrado. Instalando..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install git curl wget gpg
  elif [[ "$OS" == "Linux" ]]; then
    echo "Instalando dependências no Linux..."
    if [ -f /etc/fedora-release ]; then
      sudo dnf install -y git curl wget tar gzip bzip2 xz gcc make libffi-devel bzip2 bzip2-devel zlib-devel readline-devel sqlite sqlite-devel gpg
    elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
      sudo apt update
      sudo apt install -y git curl wget tar gzip bzip2 xz-utils build-essential libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev gnupg
    else
      echo "Distribuição Linux não suportada automaticamente. Instale as dependências manualmente."
    fi
  else
    echo "Sistema não suportado: $OS"
    exit 1
  fi
}

# Instala dependências
install_dependencies

# Instala asdf
if [ ! -d "$HOME/.asdf" ]; then
  echo "Clonando asdf..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
else
  echo "asdf já existe, atualizando..."
  git -C ~/.asdf pull
fi

# Detecta shell e arquivo RC correto
SHELL_RC="$HOME/.bashrc"
COMPLETIONS_FILE="$HOME/.asdf/completions/asdf.bash"
if [[ "$SHELL" == *"zsh"* ]]; then
  SHELL_RC="$HOME/.zshrc"
  COMPLETIONS_FILE="$HOME/.asdf/completions/asdf.zsh"
fi

# Configura shell
if ! grep -q "asdf.sh" "$SHELL_RC"; then
  echo "Configurando shell..."
  echo -e "\n# Configuração asdf" >> "$SHELL_RC"
  echo -e ". \$HOME/.asdf/asdf.sh" >> "$SHELL_RC"
  echo -e ". $COMPLETIONS_FILE" >> "$SHELL_RC"
fi

# Carrega configuração no shell atual
# Apenas funciona em shells interativos
if [[ "$SHELL" == *"bash"* || "$SHELL" == *"zsh"* ]]; then
  source "$SHELL_RC"
fi

echo "asdf instalado com sucesso!"
