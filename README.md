# b2d
Prepare the environment for running boot2docker on Windows, even behind corporate proxy.

Context: http://stackoverflow.com/a/29303930/6309

## `senv.bat`

Set the environment variables and path for Git, Boot2Docker and VirtualBox.  
Define aliases for VBoxManage (in order to expose ports on VirtualBox boot2docker vm easily)

The `env.bat` is supposed to be in the parent folder of the repo, in order to not been committed and pushed by mistake   
(since it can include proxy environment vith username:password in it)
