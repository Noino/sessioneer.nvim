# Sessioneer - a Neovim Session Manager for me

Sessioneer is a Neovim plugin that leverages Neovim’s built-in :mksession to automatically save and restore your session buffers and layouts when opening Neovim in a directory. It works quietly in the background so you can focus on your work without worrying about session management.

## Features

 -   Automatic Session Management:
    Sessions are saved when you enter or leave buffers, or exit Neovim and restored automatically when you open a directory, ensuring a smooth workflow.

 -   Directory-Based Sessions:
    Each session is associated with a directory. This makes it easy to maintain context-specific environments for your projects.

 -   Seamless Integration:
    Utilizes Neovim's native :mksession functionality and enhances it with a hands-off approach.

 -   Lightweight & Fast:
    With minimal dependencies and efficient code, Sessioneer keeps your startup times low.

 -   Unconfigurable:
    I mean you could if you wanted to, but its really built for me the way i want my sessions to work because i couldn't get one of the existing ones to do it


## Installation

If you are using a plugin manager like lazy.nvim, you can add Sessioneer as follows:

### lazy.vim
```lua
return {
    'noino/sessioneer.nvim',
    cond = function()
        return not vim.g.utility_mode
    end,
    config = function()
        require('sessioneer').setup {}
    end
}
```

For other plugin managers, please refer to their documentation for installation instructions.

## Usage

Once installed, Sessioneer works automatically:

    Auto Save:
    When you enter or leave buffers, or exit Neovim, the plugin saves your current buffers and window layout to a session file specific to the directory.

    Auto Restore:
    When you open Neovim in a directory with a previously saved session, it restores the session seamlessly.

Example of how i utilize this can be gleaned from [my configs](https://github.com/Noino/hyprlander) (which i use both on KDE and Hyprland)

## Commands

maybe later?

## Configuration Options

The setup function accepts a table of options to customize Sessioneer’s behavior. Here’s an overview of available options:

    auto_restore (boolean):
    Enable or disable automatic session restoration when opening Neovim in a directory.
    Default: true

    session_dir (string):
    The directory where session files will be stored.
    Default: vim.fn.stdpath('data') .. '/session'

    git_branches (boolean):
    Enable or disable differentiating sessions based on your branch (TODO: needs work probably)
    Default: true

## Contributing

Contributions are welcome! If you have suggestions, bug fixes, or improvements:

Please open an issue or submit a pull request on GitHub.
Ensure your code follows the existing style guidelines.

I'll get to it when i get to it, maybe

## License

Sessioneer is released under the MIT License.

Sessioneer also includes a logging module yoinked from https://github.com/rmagatti/auto-session
released under MIT (It's license inline)

## Acknowledgments

Thanks to the Neovim community for inspiring plugin ideas and best practices.
