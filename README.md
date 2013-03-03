# Examples
This is a generic website backup script, with the twist being that
it creates a versioned repository of file list modifications, so that one
can track the appearance, growth, and disappearance of files.

It does not git the entire database or filesystem. That would be madness.

## General Requirements

### [git](http://git-scm.com/downloads)

If in a Debian/Ubuntu-style distro: `sudo apt-get install git`

### [rsync](http://rsync.samba.org/)
Don't worry about installing this remotely.

If in a Debian/Ubuntu-style distro: `sudo apt-get install rsync`

### [sshfs](http://fuse.sourceforge.net/sshfs.html)

If in a Debian/Ubuntu-style distro: `sudo apt-get install sshfs`

### ssh
If you're not hip to host ssh public keys and aliases, you're in for a treat.

The following steps will enable you to completely automate the process.

#### 1. Create or edit `~/.ssh/config` ...

    Host myalias
    HostName myhost.com
    User myusername

Now you can type `ssh myalias` instead of `ssh myusername@myhost.com`.

#### 2. Next, ditch the password. Make yourself a pair of public and private keys.

    `ssh key-gen -t rsa`

Stick with the default options.

#### 3. Create the remote `.ssh` folder if it's not already there.

    `ssh myalias mkdir -p ~/.ssh`

You'll be prompted for your password. That's okay.

#### 4. Append your public key to `authorized_keys` on the remote `.ssh` folder

    `cat ~/.ssh/id_rsa.pub | ssh myalias 'cat >> .ssh/authorized_keys'`

You'll be prompted for your password again. Hopefully for the last time.

#### 5. Test it.

    `ssh myalias`

If you did it right, you should have automatically logged in to the remote
server. After you're done marveling, type `exit` to return to your box.

## Installing

* Download it

** If you're down with *git*...

    `git clone git@github.com:wikitopian/bagitup.git`

** If you're not, just download it and unzip it...

    `wget https://github.com/wikitopian/backup/archive/master.zip`

## Configuring

### example.bagituprc
This is what you will edit and paste into your home folder as `.bagituprc` to
include your specific servers.

## Running

* Execute the `bagitup.sh` script.

## Known issues
None, ...yet.
