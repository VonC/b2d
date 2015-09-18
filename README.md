# b2d
Prepare the environment for running boot2docker on Windows, even behind corporate proxy.

Context: http://stackoverflow.com/a/29303930/6309

## `senv.bat`

Set the environment variables and path for Git, Boot2Docker and VirtualBox.  
Define aliases for VBoxManage (in order to expose ports on VirtualBox boot2docker vm easily).  
The goal is to have a *minimal* Windows path, avoiding any side-effect from other programs.

The `env.bat` is supposed to be in the parent folder of the repo, in order to not been committed and pushed by mistake   
(since it can include proxy environment vith username:password in it)

It should also define `HOME` (to the parent folder of the b2d repo) in order to not be influenced by any existing global git config (`.gitconfig`) in the default git `HOME` (`%USERPROFILE%` on Windows)

## Commands

Once the env.bat is properly filled out, you need to:

- execute senv.bat (in a DOS prompt) or source senv.sh (in a git bash, even on Windows)
- type `b` for building all the images
- type `s` to start all the containers
- type `st` to stop and remove all the containers
