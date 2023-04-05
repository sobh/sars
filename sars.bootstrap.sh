#!/bin/sh
#
# Description: Bootstrap the Sobh Awsoem Rice System
#

#---- Parameters ---------------------------------------------------------------
USERNAME="Mohamed Sobh"
EMAIL="mohamed.alhusieny@gmail.com"
DOTFILES_REPO="git@github.com:sobh/dotfiles"
UPKG_REPO="git@github.com:sobh/upkg"

OS=""
DOAS=""

ARCH_PKGS="openssh git"
#---- Constatns ----------------------------------------------------------------
REPOS_DIR="$HOME/repos"
PERSONAL_REPOS="$REPOS_DIR/$(whoami)"

SUPPORTED_DOAS="doas, sudo"
SUPPORTED_OS="Alpine Linux, Arch Linux, Void Linux, OpenBSD"

# Escape Colors
ESC="\e"
RESET="$ESC[0m"
FG_RED="$ESC[91m"
FG_GREEN="$ESC[92m"
FG_YELLOW="$ESC[93m"
FG_BLUE="$ESC[94m"
FG_MAGENTA="$ESC[95m"
FG_CYAN="$ESC[96m"

#---- Functions ----------------------------------------------------------------
#
#-------- Status -----------------------
info()		{ printf "${FG_BLUE}%-8s$RESET: %s\n" "Info" "$*"; }
warning()	{ printf "${FG_YELLOW}%-8s$RESET: %s\n" "Warning" "$*"; }
error()		{ printf "${FG_RED}%-8s$RESET: %s\n" "Error" "$*"; }

#-------- OS Probing -------------------
getos()
{
	# For our purpose we only care about the upstream indenpendant distros.
	command -v apk 2>&1 >/dev/null && { echo alpine; return 0;}
	command -v pacman 2>&1 >/dev/null && { echo arch; return 0;}
	command -v pkg_add 2>&1 >/dev/null && { echo openbsd; return 0;}
	command -v xbps-install 2>&1 >/dev/null && { echo void; return 0;}
	echo unknown
	return 1
}
getdoas()
{
	command -v doas 2>&1 >/dev/null && { echo doas; return 0;}
	command -v sudo 2>&1 >/dev/null && { echo sudo; return 0;}
	echo unknown
	return 1
}

#-------- Bootstrap --------------------

bootstrap_alpine()
{
	error "Alpine Linux bootstrap is WIP."
}

bootstrap_arch()
{
	info "Updating Package Cache..."
	$DOAS pacman -Sy

	info "Installing crucial packages..."
	$DOAS pacman -S --needed $ARCH_PKGS

	info "Installing the Universal Package Manager 'upkg'."
	cd $PERSONAL_REPOS
	[ ! -d upkg ] && git clone $UPKG_REPO
	$DOAS install $PERSONAL_REPOS/upkg/upkg-arch /usr/local/bin/upkg
}

bootstrap_openbsd()
{
	error "OpenBSD bootstrap is WIP."
}

bootstrap_void()
{
	error "Void Linux bootstrap is WIP."
}

bootstrap()
{
	# Insure that the repos directory exists.
	mkdir -p $PERSONAL_REPOS 2>&1 > /dev/null
	os=$1
	case arch in
		alpine)		bootstrap_alpin ;;
		arch)		bootstrap_arch ;;
		openbsd)	bootstrap_openbsd ;;
		void)		bootstrap_void ;;
		*) error "Operating System $os is not supported."
	esac
}

#-------- dotfiles ---------------------
summon_dotfiles ()
{
	dir=$1
	repo=$2
	if [ ! -d $dir ]; then
		error "$dir directory does not exist."
		return 1
	fi
	if [ -d "$dir/.git" ]; then
		warning "There is already a '.git' in the $HOME directory. Skipping dotfiles setup..."
		return 1;
	fi
	cd $dir
	git init --initial-branch=master
	git remote add origin "$repo"
	git fetch
	git checkout --force master
}
#---- Main ---------------------------------------------------------------------

#---- Probe System ---------------------
OS=$(getos)
DOAS=$(getdoas)

echo
if [ "$OS" = "unkown" ]; then
	error "System is not supported. Not in ($SUPPORTED_OS)."
	exit 1
fi
info "Detected Operating System $OS."

if [ "$DOAS" = "unkown" ]; then
	error "Unable to find a supported privilege escalation command. Not in ($SUPPORTED_DOAS)."
	exit 1
fi
info "Detected privilege escalation command $DOAS."

#---- Bootstrap ------------------------
bootstrap $OS

info "Configuring git..."
( set -x; git config --global user.name "$USERNAME"; )
( set -x; git config --global user.email "$EMAIL"; )

#---- Dotfiles -------------------------
summon_dotfiles "$HOME" "$DOTFILES_REPO"
