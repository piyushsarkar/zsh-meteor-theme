# Meteor Theme for ZSH

<p align="center">
  <img src="https://user-images.githubusercontent.com/50408944/229354610-a8b39cb9-742d-474b-8c2c-6f6263519c54.svg" alt="icon" height="50">
  <p align="center">Elevate your terminal experience with sleek and minimal meteor theme.</p>
</p>

![Terminal](https://user-images.githubusercontent.com/50408944/229465242-58161b45-b98c-4ec5-a21a-fce5ba145ea5.png)

## Installation

### Recommended Installation:

1. Run this command in your terminal, it will install the theme and add it to your `.zshrc` file automatically.

   ```sh
   curl -sS https://raw.githubusercontent.com/piyushsarkar/zsh-meteor-theme/main/install.sh | sh
   ```

2. That's it! Restart your terminal and you're good to go.

### Manual Installation:

1. Clone this repository into `~/.zsh`

   ```sh
   git clone https://github.com/piyushsarkar/zsh-meteor-theme ~/.zsh/zsh-meteor-theme
   ```

2. Add source path of `zsh-meteor-theme` inside `~/.zshrc`:

   ```sh
   source ~/.zsh/zsh-meteor-theme/meteor.zsh
   ```

3. Start a new terminal session.

## Uninstall

1. Remove the `zsh-meteor-theme` folder

   ```sh
   rm -rf ~/.zsh/zsh-meteor-theme
   ```

2. Remove `source ~/.zsh/zsh-meteor-theme/zsh-meteor-theme.zsh` from `.zshrc`

   ```sh
   echo "$(grep -v "source ~/.zsh/zsh-meteor-theme/meteor.zsh" ~/.zshrc)" > ~/.zshrc
   ```

3. Restart your terminal.
