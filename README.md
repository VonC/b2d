# b2d
Prepare the environment for running boot2docker on Windows, even behind corporate proxy.

Context: http://stackoverflow.com/a/29303930/6309

## `senv.bat`

Set the environment variables and path for Git, Boot2Docker and VirtualBox.  
Define aliases for VBoxManage (in order to expose ports on VirtualBox boot2docker vm easily).  
The goal is to have a *minimal* Windows path, avoiding any side-effect from other programs.

`senv.bat` calls a private (not versionned) `env.bat`.  
The `env.bat` is supposed to be in the parent folder of the repo, in order to not been committed and pushed by mistake   
(since it can include proxy environment settings, with username:password in it)

It should also define `HOME` (to the parent folder of the b2d repo) in order to not be influenced by any existing global git config (`.gitconfig`) in the default git `HOME` (`%USERPROFILE%` on Windows)

## Commands

Once the `env.bat` is properly filled out, you need to:

- execute `senv.bat` (in a DOS prompt) or `source senv.sh` (in a git bash, even on Windows). In both cases, it will call the private `env.bat`.
- type `b` for building all the images
- type `s` to start all the containers
- type `st` to stop and remove all the containers

## Tests

That repo comes with Dockerfiles specifying a **full git repo hosting server** (complete with a gitweb, an ssh listener, an Apache http listener, a NGiNX rever-proxy server, and LDAP authentication)

Typing `s` will launch actually 3 sets of containers, meaning 3 different Git hosting servers (called "blessed", "staging" and "external")

Typing `t` will launch a series of tests to check if those Git servers are working as expected.

## Goal: commit replication accross 3 servers

The goal is to facilitate the collaboration between collaborators within a company and external contributors who have no access to the company git repos.

To that effect, commits done on a branch in "blessed" should be replicate to the "external" repo (through "staging").  
Commits done on a branch in "external" will be replicated (through "staging" pull) to "blessed" ("external" has no idea that "blessed" or "staging" exist, since those are internal company servers: an *external* server should not be aware of those).

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

## Applicative Architecture

Each git repo hosting server follows the same appllicative archicture:

````
+--------------------------------------------------------------------------------+
|                            Git repo hosting server                             |
|                                                                                |
|   +-----------+           +-----------+                       +-----------+    |
|   |           +---------> |           |                       |           |    |
|   | NGiNX     |     +-----+ Apache    +------------------+--> | LDAP      |    |
|   |           |     |     |           |                  |    |           |    |
|   +-----------+     |     +---+-------+                  |    +-----------+    |
|                     |         |                          |                     |
|   +-----------+     |         v                          |    +-----------+    |
|   |           |     |      XXXXXX                        |    |           |    |
|   | SSHD      |     |     X      X                       +--> | Gpg2      |    |
|   |           |     |     |XXXXXX|-------+               |    |           |    |
|   +-----+-----+     |     | git  | Hooks |               |    +-----------+    |
|         |           |     | repos|-------+               |                     |
|   +-----v-----+     |     \--+---/        +-----------+  |    +-----------+    |
|   |           |     |        ^            |           |  +--> |           |    |
|   | Data      |     |        |            | MCron     |       | Gitolite  |    |
|   |           | <---+--------+------------+           +-----> |           |    |
|   +-----------+                           +-----------+       +-----------+    |
+--------------------------------------------------------------------------------+
````

You can start each environment separately:

* `re`: run external (`ke`: stops and rm external containers)
* `rs`: run staging (`ks`: stops and rm staging containers)
* `rb`: run blessed (`kb`: stops and rm blessed containers)

The order is important, and that is what `start` (or alias `s` mentioned above) will do: run each environment,; starting with extenal, then staging, then blessed, then "mcron staging" (which needs to know about external, from which it pulls, and blessed, to which it pushes)

### NGiNX:

Allows to access to https://localhost:8443/hgit (git clone url) or https://localhost:8443/git (bit web url) through the same port number.

### Apache:

Allows to:

* authenticate the user (with LDAP)
* authorize the user (with gitolite)
* browse git repos (only the ones the user is authorized for)
* clone git repos (only the ones the user is authorized for)
 
### LDAP:

Include a list of test accounts ([`openldap/users-usecases.ldif`](https://github.com/VonC/b2d/blob/master/openldap/users-usecases.ldif) and [`openldap/users-usecases.ldif`](https://github.com/VonC/b2d/blob/master/openldap/users-usecases.ldif))

### Gpg2:

Allows to keep some service account (like `projextprdr`) password in an encrypted file

### Gitolite

Authorize users to access git repos

### MCron:

Execute jobs on schedule:

* [`mcron/pull_external`](https://github.com/VonC/b2d/blob/master/mcron/pull_external): fetch from external and push to blessed
* [`mcron/clean_shipping_bay`](https://github.com/VonC/b2d/blob/master/mcron/clean_shipping_bay): clean the new commit markers in staging, once the fetch has been done by `pull_external`.
 
### Data:

Data volume container for the shipping_bay (commits markers on external, in order for staging to know from which repos to pull, instead of having to pull from *all* repos).

### SSHD:

SSH access to external, in order to list (`ls`) the commits markers in the external shipping_bay data container.
