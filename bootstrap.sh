#!/bin/sh
#
# Description: Bootstrap the Sobh Awsoem Rice System
#

#---- Parameters ---------------------------------------------------------------
# Defaults
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
USERNAME="Mohamed Sobh"
EMAIL="mohamed.alhusieny@gmail.com"
DOTFILES_REPO="git@github.com:sobh/dotfiles"
UPKG_REPO="git@github.com:sobh/upkg"

OS=""
DOAS=""

BASE_PKGS="git"
ARCH_PKGS="openssh fakeroot"
ARCH_AUR_HELPER="yay-bin"

#---- Constants ----------------------------------------------------------------
MY_DIR=$(dirname $0)
REPOS_DIR="$HOME/repos"
PERSONAL_REPOS="$REPOS_DIR/$(whoami)"

SUPPORTED_DOAS="doas, sudo"
SUPPORTED_OS="Alpine Linux, Arch Linux, Void Linux, OpenBSD"
SUPPORTED_FF="desktop, laptop, server"

# Escape Colors
ESC="\033"
RESET="$ESC[0m"
FG_RED="$ESC[91m"
FG_GREEN="$ESC[92m"
FG_YELLOW="$ESC[93m"
FG_BLUE="$ESC[94m"
FG_MAGENTA="$ESC[95m"
FG_CYAN="$ESC[96m"

#---- Functions ----------------------------------------------------------------

#-------- Status -----------------------
SARS_PREFIX="${FG_MAGENTA}SARS | "
info()		{ printf "${SARS_PREFIX}${FG_BLUE}%-8s$RESET: %s\n" "Info" "$*"; }
warning()	{ printf "${SARS_PREFIX}${FG_YELLOW}%-8s$RESET: %s\n" "Warning" "$*"; }
error()		{ printf "${SARS_PREFIX}${FG_RED}%-8s$RESET: %s\n" "Error" "$*"; }

#-------- Usage ------------------------
usage()
{
	cat << _EOF

$(basename $0)  FORM_FACTOR

Parameters:
	FORM_FACTOR     The machine form factor. One of: $SUPPORTED_FF

_EOF
}
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
	$DOAS pacman -S --needed --noconfirm $BASE_PKGS $ARCH_PKGS

	info "Installing the AUR Helper '$ARCH_AUR_HELPER'."
	helper_repo="https://aur.archlinux.org/$ARCH_AUR_HELPER"
	aur_cache="$XDG_CACHE_HOME/aur"
	mkdir -p $aur_cache; cd $aur_cache
	[ ! -d $ARCH_AUR_HELPER ] && git clone $helper_repo
	cd $ARCH_AUR_HELPER && git pull
	makepkg -si --noconfirm --needed

}

bootstrap_openbsd()
{
	info "Installing crucial packages..."
	$DOAS pkg_add $BASE_PKGS
}

bootstrap_void()
{
	info "Installing crucial packages..."
	$DOAS xbps-install $BASE_PKGS
}

bootstrap()
{
	# Insure that the repos directory exists.
	mkdir -p $PERSONAL_REPOS 2>&1 > /dev/null
	os=$1
	case $os in
		alpine)		bootstrap_alpine ;;
		arch)		bootstrap_arch ;;
		openbsd)	bootstrap_openbsd ;;
		void)		bootstrap_void ;;
		*) error "Operating System $os is not supported."
	esac
	formfactor=$2

	# Install `upkg`
	info "Installing the Universal Package Manager 'upkg'."
	_cw=$(pwd)
	cd $PERSONAL_REPOS
	[ ! -d upkg ] && git clone $UPKG_REPO
	(set -x; $DOAS install $PERSONAL_REPOS/upkg/upkg-$os /usr/local/bin/upkg)
	cd $_cw

	# Intall the essential packages
	info "Installing the essential packages for a '$formfactor'..."
	pkgs=$("$MY_DIR/list_pkgs.awk" -v os=$os -v machine=$formfactor < "$MY_DIR/pkgs.tsv")
	$DOAS upkg install $pkgs
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
#---- Sanity Check ---------------------
FORM_FACTOR="$1"

if [ -z "$FORM_FACTOR" ]; then
	error "Please specify the machine form factor."
	usage
	exit 3
else
	case $FORM_FACTOR in
		desktop)    ;;
		laptop)     ;;
		server)     ;;
		*)
			error "Form Factor: '$FORM_FACTOR' is not supported. Not in ($SUPPORTED_FF)."
			usage
			exit 3
			;;
	esac
fi

#---- Probe System ---------------------
OS=$(getos)
DOAS=$(getdoas)

if [ "$OS" = "unkown" ]; then
	error "System is not supported. Not in ($SUPPORTED_OS)."
	exit 1
fi
info "Detected Operating System $OS."

if [ "$DOAS" = "unkown" ]; then
	error "Unable to find a supported privilege escalation command. Not in ($SUPPORTED_DOAS)."
	exit 2
fi
info "Detected privilege escalation command $DOAS."

#---- Bootstrap ------------------------
bootstrap $OS $FORM_FACTOR

info "Configuring git..."
( set -x; git config --global user.name "$USERNAME"; )
( set -x; git config --global user.email "$EMAIL"; )

#---- Set Default Shell ----------------
info "Setting the default shell to zsh..."
chsh -s $(grep zsh /etc/shells | head -n1) $USER

#---- Dotfiles -------------------------
summon_dotfiles "$HOME" "$DOTFILES_REPO"
