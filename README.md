# 💥 lazy.zsh

**lazy.zsh** is a lightweight and no non-sense zsh plugin manager.

## 🛠Quick Guide

### ⚡️ Requirements

- git

### 📦 Installation

- Add the following code to your `.zshrc`.

  ```sh
  # --- lazy.zsh configurations:start --->
  # your plugins
  declare LAZYZ_PLUGINS=(
      # romkatv/powerlevel10k              # github short url
      # zsh-users/zsh-syntax-highlighting
      https://github.com/ndachj/lazy.zsh # full url
  )

  export LAZYZ="$HOME/.local/share/lazyz" # where to save plugins
  export LAZYZ_UPDATE_REMAINDER=true      # set a reminder
  export LAZYZ_UPDATE_INTERVAL=14         # update interval(days)

  # bootstrap lazy.zsh
  function -lazyz_bootstrap(){
      if ! source "${LAZYZ}/lazy.zsh/lazy.zsh"; then
          if command -v git &>/dev/null; then
              rm -rf "${LAZYZ}/" &>/dev/null
              git clone --depth=1 'https://github.com/ndachj/lazy.zsh' "${LAZYZ}/lazy.zsh"
          else
              echo "[lazyz]: lazy.zsh couldn't be installed."
          fi
      fi
  }
  -lazyz_bootstrap
  # --- lazy.zsh configurations:end --->
  ```

- Source the `.zshrc` or restart your terminal.

  ```sh
  source ~/.zshrc
  ```

- Run `lazyz help` to see all available commands.

## ⌨️ Hacking

- To install a plugin, add the repo url (either github short url or full url) to the `LAZYZ_PLUGINS` array.

  > [!NOTE]
  > This means that you will have the same zsh plugins as long as you use the same `.zshrc`

- To get a reminder to update your plugins, set `LAZYZ_UPDATE_REMAINDER=true`.

- `LAZYZ_UPDATE_INTERVAL` is how often(in days) you want to get the remainder.

### 🔎 Missing Features

This plugin manager doesn't load any plugins, but knows they exist. To achieve that you need to manually load them in your `.zshrc`. For example:

```sh
# powerlevel10k zsh theme
source "$LAZYZ/powerlevel10k/powerlevel10k.zsh-theme"
```

### 💤 Uninstall

<details><summary>To uninstall lazy.zsh</summary>

- Remove the [above code](https://github.com/ndachj/lazy.zsh#installation) from your `.zshrc`
- Remove the plugins directory

```sh
rm -rfI "$LAZYZ"
```

</details>

## 🌐 Other Resources

- [autoupdate-oh-my-zsh-plugins](https://github.com/tamcore/autoupdate-oh-my-zsh-plugins) - oh-my-zsh plugin for auto updating of git-repositories in $ZSH_CUSTOM folder

- [zgen](https://github.com/tarjoilija/zgen) - A lightweight plugin manager for Zsh inspired by Antigen

- [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) - A collection of ZSH frameworks, plugins, tutorials & themes inspired by the various awesome list collections out there.
