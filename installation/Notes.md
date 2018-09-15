# General Notes:
I try to minimize the number of installed packages as small as possible, and to only use free software, wherever possible. This is 
I also try to adhere to the following priorities regarding packages/software:

Software priorities
---

1. Use a package from the official repositories for a certain purpose.
2. If there is none, use a package from the AUR
3. If I need software that is neither in the official repositories nor the AUR, I will create a package myself and host it on my custom repo/the AUR/both.

This is not without exceptions:
* Software that is installed on a per-user basis can be installed using other solutions
  (pip, gems, node packages). This is software that should not be mission critical.
* Software that is installed for a specific, encapsulated use doesn't need to have a custom package.
* Plug-Ins for other software I use can be installed using a plug-in manager rather than the arch package management. Examples include:
  * Vim
	* Zsh
	* Tmux

Generally, I want my system to be functional in a minimal state without relying on anything that is not in the official arch repositories. That includes, but is not limited to, everything shell related, my desktop environment, and development related software. Anything else should degrade gracefully.

Software maintenance
===

In addition to the information provided by e.g. `pacman -Qi <package>`, I try to organize installed packages, keeping note of the purpose/role. This should allow me to easily group packages by their role, and optionally to write notes for each package regarding their use and their alternatives. 

When installing new packages, I will immediately organize it into the existing collection. If I replace role-specific packages (e.g. browser, shell), I will either remove the old package, or I will set the defaults accordingly and add some kind of note to both packages explaining my choice of default. If possible, I will remove the obsolete package.

Ideally, I will have my system set-up in a way that automatically tracks installed packages and changes to configuration with a script that helps organize newly installed software. 

See also: [aconfmgr](https://github.com/CyberShadow/aconfmgr)
