#!/bin/bash

# Repository
REPO="Burhanverse/colloid-icon-theme"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script variables
SCHEME=""
THEME=""
NOTINT_FLAG=""
TAG=""
TEMP_DIR=$(mktemp -d)

# Show help message
show_help() {
  echo -e "${BLUE}Colloid Icon Theme Installer${NC}"
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -h, --help          Show this help message"
  echo "  -s, --scheme VALUE  Set colorscheme (default, nord, dracula, gruvbox, everforest, catppuccin, all)"
  echo "  -t, --theme VALUE   Set folder color theme (default, purple, pink, red, orange, yellow, green, teal, grey, all)"
  echo "  -n, --notint        Disable KDE Plasma color tinting"
  echo "  -y, --yes           Non-interactive mode (uses default options)"
  echo
}

# Check for dependencies
check_dependencies() {
  local missing_deps=()
  
  for cmd in curl unzip; do
    if ! command -v "$cmd" &>/dev/null; then
      missing_deps+=("$cmd")
    fi
  done
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}Error: Required dependencies not found: ${missing_deps[*]}${NC}"
    echo -e "${YELLOW}Please install them and run this script again.${NC}"
    exit 1
  fi
}

# Clean up function
clean_up() {
  echo -e "${CYAN}Cleaning up temporary files...${NC}"
  rm -rf "$TEMP_DIR"
}

# Set up trap for unexpected exits
trap clean_up EXIT INT TERM

get_latest_release_tag() {
  echo -e "${CYAN}Fetching the latest release tag...${NC}"
  
  # First try GitHub API with expanded error handling
  local api_response
  api_response=$(curl --silent -i "https://api.github.com/repos/$REPO/releases/latest")
  
  # Check HTTP status code
  local status_code
  status_code=$(echo "$api_response" | head -n 1 | grep -o "HTTP/[0-9.]* [0-9]*" | cut -d' ' -f2)
  
  case "$status_code" in
    200)
      # Success - extract tag
      TAG=$(echo "$api_response" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
      ;;
    404)
      echo -e "${YELLOW}No releases found for $REPO. Trying tags instead...${NC}"
      # Try to get tags as fallback
      local tags_response
      tags_response=$(curl --silent "https://api.github.com/repos/$REPO/tags")
      
      if [ "$tags_response" != "[]" ] && [ -n "$tags_response" ]; then
        TAG=$(echo "$tags_response" | grep -m1 '"name":' | sed -E 's/.*"([^"]+)".*/\1/')
      fi
      ;;
    403)
      echo -e "${YELLOW}GitHub API rate limit exceeded. Trying alternative method...${NC}"
      # Skip to fallback
      ;;
    *)
      echo -e "${YELLOW}GitHub API returned status code: $status_code. Trying alternative method...${NC}"
      # Skip to fallback
      ;;
  esac
  
  # If API methods failed, try HTML scraping as last resort
  if [ -z "$TAG" ]; then
    echo -e "${YELLOW}Trying alternative method to get latest tag...${NC}"
    TAG=$(curl --silent "https://github.com/$REPO/releases" | 
          grep -o 'href="/'$REPO'/releases/tag/[^"]*' | 
          head -1 | 
          sed 's|href="/'$REPO'/releases/tag/||')
  fi
  
  # If we still don't have a tag, try direct download of main branch as last resort
  if [ -z "$TAG" ]; then
    echo -e "${YELLOW}No release tags found. Using main branch instead.${NC}"
    TAG="main"
    # Adjust download URL in download_latest_release function
    USE_MAIN_BRANCH=true
    return
  fi

  echo -e "${GREEN}Latest release tag is: $TAG${NC}"
}

# Update download_latest_release to handle main branch fallback
download_latest_release() {
  if [ "${USE_MAIN_BRANCH:-false}" = true ]; then
    DOWNLOAD_URL="https://github.com/$REPO/archive/refs/heads/main.zip"
    echo -e "${CYAN}Downloading main branch from ${DOWNLOAD_URL}...${NC}"
  else
    DOWNLOAD_URL="https://github.com/$REPO/archive/refs/tags/$TAG.zip"
    echo -e "${CYAN}Downloading the release from ${DOWNLOAD_URL}...${NC}"
  fi
  
  # Use progress bar with curl
  if ! curl -L --progress-bar -o "$TEMP_DIR/latest_release.zip" "$DOWNLOAD_URL"; then
    echo -e "${RED}Failed to download from GitHub. Please check your internet connection.${NC}"
    exit 1
  fi

  echo -e "${CYAN}Extracting the zip file...${NC}"
  if ! unzip -q -o "$TEMP_DIR/latest_release.zip" -d "$TEMP_DIR"; then
    echo -e "${RED}Failed to extract the zip file.${NC}"
    exit 1
  fi

  EXTRACTED_DIR=$(unzip -Z -1 "$TEMP_DIR/latest_release.zip" | head -n 1 | cut -d '/' -f 1)
  if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "${RED}Could not determine extracted directory.${NC}"
    exit 1
  fi
  
  cd "$TEMP_DIR/$EXTRACTED_DIR" || {
    echo -e "${RED}Failed to change directory to $TEMP_DIR/$EXTRACTED_DIR${NC}"
    exit 1
  }
}

remove_old_directories() {
  echo -e "${CYAN}Checking for old Colloid-icon-theme directories...${NC}"
  # Use nullglob to handle the case where no matching directories are found
  shopt -s nullglob
  for dir in Colloid-icon-theme-*; do
    if [[ -d "$dir" ]]; then
      echo -e "${RED}Removing existing directory: $dir${NC}"
      rm -rf "$dir"
    fi
  done
  shopt -u nullglob
}

# Colorscheme
choose_scheme() {
  if [ -n "$SCHEME" ]; then
    return
  fi
  
  echo -e "${YELLOW}Choose a folder colorscheme variant:${NC}"
  echo -e "1) ${GREEN}Default${NC}"
  echo -e "2) ${GREEN}Nord${NC}"
  echo -e "3) ${GREEN}Dracula${NC}"
  echo -e "4) ${GREEN}Gruvbox${NC}"
  echo -e "5) ${GREEN}Everforest${NC}"
  echo -e "6) ${GREEN}Catppuccin${NC}"
  echo -e "7) ${GREEN}All${NC}"
  echo -e -n "${MAGENTA}Enter your choice [1-7]: ${NC}"
  read -r scheme_choice

  case $scheme_choice in
    1) SCHEME="default" ;;
    2) SCHEME="nord" ;;
    3) SCHEME="dracula" ;;
    4) SCHEME="gruvbox" ;;
    5) SCHEME="everforest" ;;
    6) SCHEME="catppuccin" ;;
    7) SCHEME="all" ;;
    *) echo -e "${RED}Invalid choice! Defaulting to 'default'.${NC}"; SCHEME="default" ;;
  esac
}

# Folder color variant
choose_theme() {
  if [ -n "$THEME" ]; then
    return
  fi
  
  echo -e "${YELLOW}Choose a folder color variant:${NC}"
  echo -e "1) ${GREEN}Blue (Default)${NC}"
  echo -e "2) ${GREEN}Purple${NC}"
  echo -e "3) ${GREEN}Pink${NC}"
  echo -e "4) ${GREEN}Red${NC}"
  echo -e "5) ${GREEN}Orange${NC}"
  echo -e "6) ${GREEN}Yellow${NC}"
  echo -e "7) ${GREEN}Green${NC}"
  echo -e "8) ${GREEN}Teal${NC}"
  echo -e "9) ${GREEN}Grey${NC}"
  echo -e "10) ${GREEN}All${NC}"
  echo -e -n "${MAGENTA}Enter your choice [1-10]: ${NC}"
  read -r theme_choice

  case $theme_choice in
    1) THEME="default" ;;
    2) THEME="purple" ;;
    3) THEME="pink" ;;
    4) THEME="red" ;;
    5) THEME="orange" ;;
    6) THEME="yellow" ;;
    7) THEME="green" ;;
    8) THEME="teal" ;;
    9) THEME="grey" ;;
    10) THEME="all" ;;
    *) echo -e "${RED}Invalid choice! Defaulting to 'default'.${NC}"; THEME="default" ;;
  esac
}

# KDE Plasma tinting option
is_kde() {
  if [[ "$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')" == *"kde"* || 
        "$(echo "$XDG_SESSION_DESKTOP" | tr '[:upper:]' '[:lower:]')" == *"kde"* ]]; then
    return 0
  else
    return 1
  fi
}

is_gnome() {
  if [[ "$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')" == *"gnome"* || 
        "$(echo "$XDG_SESSION_DESKTOP" | tr '[:upper:]' '[:lower:]')" == *"gnome"* ]]; then
    return 0
  else
    return 1
  fi
}

choose_notint() {
  # If notint flag is already set via command line, skip this
  if [ -n "$NOTINT_FLAG" ]; then
    return
  fi
  
  if is_kde; then
    echo -e "${YELLOW}Disable Follow ColorScheme for folders on KDE Plasma?${NC}"
    echo -e "1) ${GREEN}Yes${NC}"
    echo -e "2) ${GREEN}No${NC}"
    echo -e -n "${MAGENTA}Enter your choice [1-2]: ${NC}"
    read -r notint_choice

    case $notint_choice in
      1) NOTINT_FLAG="--notint" ;;
      2) NOTINT_FLAG="" ;;
      *) echo -e "${RED}Invalid choice! Defaulting to 'No'.${NC}"; NOTINT_FLAG="" ;;
    esac
  else
    echo -e "${CYAN}Not running KDE Plasma. Skipping tinting option.${NC}"
    NOTINT_FLAG=""
  fi
}

# Set defaults for non-interactive mode
set_defaults() {
  SCHEME="default"
  THEME="default"
  NOTINT_FLAG=""
  if is_kde; then
    NOTINT_FLAG=""  # Default behavior for KDE
  fi
}

# Parse command line arguments
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -s|--scheme)
        SCHEME="$2"
        shift 2
        ;;
      -t|--theme)
        THEME="$2"
        shift 2
        ;;
      -n|--notint)
        NOTINT_FLAG="--notint"
        shift
        ;;
      -y|--yes)
        NON_INTERACTIVE=true
        shift
        ;;
      *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_help
        exit 1
        ;;
    esac
  done
  
  # Validate scheme and theme if provided
  if [ -n "$SCHEME" ]; then
    case "$SCHEME" in
      default|nord|dracula|gruvbox|everforest|catppuccin|all) ;;
      *)
        echo -e "${RED}Invalid scheme: $SCHEME${NC}"
        exit 1
        ;;
    esac
  fi
  
  if [ -n "$THEME" ]; then
    case "$THEME" in
      default|purple|pink|red|orange|yellow|green|teal|grey|all) ;;
      *)
        echo -e "${RED}Invalid theme: $THEME${NC}"
        exit 1
        ;;
    esac
  fi
}

# Main
main() {
  check_dependencies
  parse_arguments "$@"
  
  echo -e "${BLUE}Starting Colloid Icon Theme Installer...${NC}"
  
  # Set defaults in non-interactive mode
  if [ "${NON_INTERACTIVE:-false}" = true ]; then
    set_defaults
  fi
  
  get_latest_release_tag
  
  # Get user choices if not in non-interactive mode
  if [ "${NON_INTERACTIVE:-false}" != true ]; then
    choose_scheme
    choose_theme
    choose_notint
  fi
  
  remove_old_directories
  download_latest_release
  
  # Create installation command
  INSTALL_CMD="./install.sh -s \"$SCHEME\" -t \"$THEME\""
  if [ -n "$NOTINT_FLAG" ]; then
    INSTALL_CMD="$INSTALL_CMD $NOTINT_FLAG"
  fi
  
  echo -e "${CYAN}Running the install script...${NC}"
  echo -e "${YELLOW}Command: $INSTALL_CMD${NC}"
  eval "$INSTALL_CMD"
  
  cd - > /dev/null
  echo -e "${GREEN}Installation completed successfully.${NC}"
}

main "$@"