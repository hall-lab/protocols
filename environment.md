# Setting up the Hall lab cluster environment

## Log in to the MGI cluster

You can log in to the cluster in one of two ways:

1. Jump box log in. This is preferred for navigating the file system, low-level processing, and launching LSF jobs. Useful when the hall nodes (hall13, hall14, hall15, hall16) are busy.
  ```bash
  # Log in to the jump box
  ssh username@ssh-jump-1.gsc.wustl.edu
  # username@ssh-jump-1.gsc.wustl.edu's password: [Enter your password]
  
  # Open an interactive node for processing
  open64
  # bsub -XF -Is -q interactive -R 'select[type==LINUX64]' /bin/bash
  # Job <9399510> is submitted to queue <interactive>.
  # <<ssh X11 forwarding job>>
  # <<Waiting for dispatch ...>>
  # <<Starting on blade14-2-4.gsc.wustl.edu>>
  ```

2. Log in directly to a Hall lab server. This is preferred for running memory- or compute-intensive interactive tasks. Be cautious of overloading the node though, as it may be hosting LSF jobs or interactive jobs from other users.
  ```bash
  # hall13, hall14, hall15, hall16 are the Hall lab blades.
  ssh username@hall13.gsc.wustl.edu
  # username@hall13.gsc.wustl.edu's password: [Enter your password]
  ```

## Hall lab directory setup

The Hall lab directory on the cluster is located at `/gscmnt/gc2719/halllab`.
It contains user directories, shared data files (such as genomes and annotations), and shared software.

Please create a directory for yourself in `/gscmnt/gc2719/halllab`, using your
first initial and last name as your username.
```bash
cd /gscmnt/gc2719/halllab
mkdir -p username
```

You are free to organize the contents of that directory as desired. However, we
recommend the following structure:

- projects
  - analysis projects, generally organized into separate publications
- src
  - external software as well as internal source code and git repositories
- bin
  - executable files that are symbolic linked to binaries in the `src` directory
- scratch
  - uncategorized and temporary analyses

You can create the above directories with the following command:
```
cd /gscmnt/gc2719/halllab/username
mkdir -p projects src bin scratch
```

## Sourcing executables
Add the following line to `~/.bashrc`

```bash
export PATH=/gscmnt/gc2719/halllab/bin:/gscmnt/gc2719/halllab/src/anaconda-2.0.1/bin:$PATH
```

## Useful `.bashrc` lines

Add any or all of these to your `~/.bashrc` file to customize your environment.
The system will automatically run this file each time you log on. If you modify it,
your changes will appear after logging out and back in, or after you run `source ~/.bashrc`.

```bash
# terminal prompt as [username@blade14-4-10 current-dir]$
export PS1='[\u@\h \W]\$ '

# For less, don't fold long lines (-S), show detailed line data (-M), ignore case when searching (-i)
# also, use zless to open gzipped files
LESS="-SMi"
alias less='zless'

# make the "ls" colors more readable on a black background
export LS_COLORS="di=01;37;44:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32"
LS_COLORS=$LS_COLORS:'*.tar=01;31'  # tar Archive             = Bold, Red
LS_COLORS=$LS_COLORS:'*.tgz=01;31'  # tar/gzip Archive        = Bold, Red
LS_COLORS=$LS_COLORS:'*.tbz2=01;31' # tar/bzip2 Archive       = Bold, Red
LS_COLORS=$LS_COLORS:'*.Z=01;31'    # compress Archive        = Bold, Red
LS_COLORS=$LS_COLORS:'*.gz=01;31'   # gzip Archive            = Bold, Red
LS_COLORS=$LS_COLORS:'*.bz2=01;31'  # bzip2 Archive           = Bold, Red
LS_COLORS=$LS_COLORS:'*.zip=01;31'  # zip Archive             = Bold, Red
LS_COLORS=$LS_COLORS:'*.dmg=01;31'  # Disk Image              = Bold, Red

# human readable directory listing sorted by recently modified
alias l='ls --color -lhtr'
```

## Transferring data between the cluster and your computer
Transfer from the cluster to your computer
```bash
rsync -avl hall16:/remote/path/to/file.txt ~/local/path/.
```

Transfer from your computer to the cluster
```bash
rsync -avl ~/local/path/to/file.txt  hall16:/remote/path/.
```

## Password-less log in
By default, you are required to enter in your password each time you access the cluster.
To save time, you can grant password-less access for your lab computer with RSA keys.

On your laptop:
```bash
cd ~/.ssh/

ssh-keygen -t rsa
# Generating public/private rsa key pair.
# Enter file in which to save the key (/Users/username/.ssh/id_rsa):
# Enter passphrase (empty for no passphrase):
# Enter same passphrase again:
# Your identification has been saved in /Users/username/.ssh/id_rsa.
# Your public key has been saved in /Users/username/.ssh/id_rsa.pub.
# The key fingerprint is:
# y8:20:3f:z9:ab:31:c9:94:3b:kc:e4:0d:4c:dd:3c:f9 username@laptop.local
# The key's randomart image is:
# +--[ RSA 2048]----+
# |                 |
# |                 |
# |                 |
# |       . o o .   |
# |    . o Z . =    |
# |     o X .   o   |
# |      * @     E  |
# |       O =       |
# |      ..=..      |
# +-----------------+

# Copy the contents of `id_rsa.pub` to your clipboard
cat id_rsa.pub
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5JGfmgoqjwZs3S5v87Yph7hBwK046EPdAlJ4nxqUDT21kRSfrtdLvezhugg68CGjODCG91V9ABAQC5JGfmgoqjwZs3S5v87Yph7hBwKTx5Nok2tNoJUoMNSCyloNhtQGKFAugexhvcdz57wGzsWzmZGaxPZeLpUxcTWn3MljROT8oU52wUBcfTMSJQfCerqmw+DFVoSkSlO/mhP7tmZxzAL0baRKSZHhEf2vhMfJxLABhUFjeCyWp7MWzEQd+NZ4I1F8AcoxYepM1FaykreCEWC72fcQz9iz226dOrnsaNxj0dOC1sAY5ysSAkyD username@laptop.local

# Set the proper permissions on your keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
```

On the MGI cluster:
```bash
mkdir -p ~/.ssh
cd ~/.ssh

# edit the `authorized_keys` file on the server
nano ~/.ssh/authorized_keys
# paste in the public key from above, then save the file (ctrl + o) and exit (ctrl + x)

# Set the proper permissions on your keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*

```

## Automatically search GSC domains
This allows you to type `ssh user@hall16` rather than `ssh user@hall16.gsc.wustl.edu` when logging in.

1. Navigate to the "Network" preference pane on your computer  
![Network 1](etc/figures/network01.png?raw=true "Network 1")

2. Select "Advanced..."  
![Network 2](etc/figures/network02.png?raw=true "Network 2")

3. Navigate to the "DNS" tab, click the "+" button and add "gsc.wustl.edu" to your search domains  
![Network 3](etc/figures/network03.png?raw=true "Network 3")
