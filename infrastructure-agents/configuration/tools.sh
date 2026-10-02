export DEBIAN_FRONTEND=noninteractive

sudo echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

sudo add-apt-repository main
sudo add-apt-repository restricted
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt update

sudo apt-get clean && apt-get update && apt-get upgrade
sudo apt-get install -y --no-install-recommends \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  jq \
  libasound2 \
  libgbm-dev \
  libgconf-2-4 \
  libgtk2.0-0 \
  libgtk-3-0 \
  libnotify-dev \
  libnss3 \
  libxss1 \
  libxtst6 \
  lsb-release \
  openjdk-17-jdk \
  software-properties-common \
  unzip \
  wget \
  xauth \
  xvfb \
  zip

sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository ppa:deadsnakes/ppa

# Git
sudo apt install -y --no-install-recommends \
  git \
  git-lfs \
  git-ftp

# Python
# Python(Ubuntu 22 uses 3.10 by default)
sudo apt-get install -y --no-install-recommends \
  python3 \
  python3-distutils \
  python3-pip

# Build dependencies required by pyenv to compile Python (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
sudo apt-get install -y --no-install-recommends \
  libbz2-dev \
  libffi-dev \
  liblzma-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libxml2-dev \
  libxmlsec1-dev \
  tk-dev \
  xz-utils \
  zlib1g-dev

# Install pyenv using the official git-clone method from the pyenv docs.
if [ ! -d /opt/pyenv ]; then
  sudo git clone https://github.com/pyenv/pyenv.git /opt/pyenv
else
  sudo git -C /opt/pyenv pull --ff-only
fi

# Make pyenv available in the current shell session.
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init - bash)"

# Make pyenv available to all future login shells on the image.
sudo tee /etc/profile.d/pyenv.sh > /dev/null <<'EOT'
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
EOT
sudo chmod 644 /etc/profile.d/pyenv.sh

pyenv --version

pyenv install -s 3.11
pyenv global 3.11

# Python dependencies
## Requirements for the tests
python3 -m pip install -r tests_requirements.txt

# Install Poetry
python3 -m pip install -U poetry==2.1.3

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install -y terraform=1.16.1-1

# Checkov
python3 -m pip install --upgrade "pyopenssl>=23.2.0" # Force an update to avoid a version conflict with cryptography
python3 -m pip install --force-reinstall packaging==21
python3 -m pip install -U checkov==3.2.529

# ODW Common
python3 -m pip install --force-reinstall "git+https://github.com/Planning-Inspectorate/odw-common.git@main"

# The ADO agent runs steps with --noprofile, so expose pyenv shims via /usr/local/bin (ahead of /usr/bin on PATH)
pyenv rehash
for shim in "$PYENV_ROOT"/shims/*; do
  ln -sf "$shim" "/usr/local/bin/$(basename "$shim")"
done

# TFLint (upstream removed the install_linux.sh auto-install script)
curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip
unzip tflint_linux_amd64.zip
sudo install -c -v tflint /usr/local/bin/
rm tflint_linux_amd64.zip

# Set up Node.js 22.x
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt-get install nodejs

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Azure Tools
sudo curl -fsSL https://aka.ms/install-azd.sh | bash

# Microsoft SQL Server ODBC Driver 18
echo "Installing Microsoft SQL Server ODBC Driver 18"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
# Install ODBC driver and development headers together
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev
echo "ODBC Driver 18 and development headers installation completed"

# .NET Core and PowerShell
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update; \
  sudo apt-get install -y aspnetcore-runtime-6.0 && \
  sudo apt-get install -y powershell

## Keep waagent on the system Python used by walinuxagent
sudo apt-get install -y walinuxagent

# PowerShell Modules
pwsh -c "& {Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force -Verbose}"
pwsh -c "& {Get-Module -ListAvailable}"

# Configure Azure DNS for Synapse Private Link resolution jira reference https://pins-ds.atlassian.net/browse/DEV-818
echo "Configuring Azure DNS..."

sudo mkdir -p /etc/systemd/resolved.conf.d

cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/azure-dns.conf
[Resolve]
DNS=168.63.129.16
EOF

sudo systemctl restart systemd-resolved

echo "Azure DNS configured"

echo "===== Installed Python version ====="
echo "python3 path: $(command -v python3)"
python3 --version
python3 -m pip --version
echo "pyenv global: $(pyenv global)"
pyenv versions
echo "System python3: $(/usr/bin/python3 --version)"
echo "/usr/local/bin/python3: $(/usr/local/bin/python3 --version)"
echo "checkov path: $(command -v checkov)"
checkov --version
echo "===================================="

# Deprovision for image capture
sudo env -i \
  HOME="$HOME" \
  PATH="/usr/sbin:/usr/bin:/sbin:/bin" \
  /usr/sbin/waagent -force -deprovision+user

export HISTSIZE=0
sync
