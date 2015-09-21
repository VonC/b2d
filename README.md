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

## Tests

That repo comes with Dockerfiles specifying a full git repo hosting server (complete with a gitweb, an ssh listener, an Apache http listener, a NGiNX rever-proxy server, and LDAP authentication)

Typing `s` will launch actually 3 sets of containers, meaning 3 different Git hosting servers (called "blessed", "staging" and "external")

Typing `t` will launch a series of tests to check if those Git server are working as expected.

## Goal: commit replication accross 3 servers

The goal is to facilitate the collaboration between collaborators within a company and external contributors who have no access to the company git repo.

To that effect, commits done on a branch in "blessed" should be replicate to the "external" repo (through "staging").  
Commits done on a branch in "external" will be replicated (through "staging" pull) to "blessed" ("external" has no idea that "blessed" or "staging" exist, since those are internal company server: an external server should not be aware of those).

````
                      3 repos hosting git servers                     +                               
                                                                      |                               
+--------------------+                   +--------------------+       |       +--------------------+  
|                    |      push         |                    |     push      |                    |  
|                    +------------------->                    +-------+------->                    |  
|       Blessed      |                   |       Staging      |       |       |      External      |  
|                    |                   |                    XXXXXXXX|XXXXXXX|                    |  
|                    |      push         |                    |     fetch     X                    |  
|                    <-------------------+                    <-XXXXXX|XXXXXXX|                    |  
+--------------------+                   +--------------------+       |       +--------------------+  
                                                                      |                               
                                                                      |                               
          2 servers inside the company:                               | One server outside the company
          * one acting as the main referential for dev (blessed)      | (external)                    
          * one in the DMZ (staging)                                  | Unaware of the 2 other servers
                                                                      + existence.
````
