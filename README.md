# packer-vsphere-centos-7

This Packer config builds a vanilla, updated CentOS 7 template.

## Usage

```
packer init -var-file=./example/config.pkrvars.hcl .
packer build -var-file=./example/config.pkrvars.hcl .
```

## Environment

Config files for each separate virtual environment are stored in a separate repository or sub-folder (see /example).
This allows for separate CI/CD pipelines and customization for each environment.

### Environment variables

Define these environment variables on your system or in your CI/CD pipeline:

```
export PKR_VAR_vsphere_username="username"
export PKR_VAR_vsphere_password="secretpassword"
```

These environment variables are required by Packer to connect up to the vCenter server.

## Credentials

Users are defined in `http/ks.cfg`.  Subiquity takes that info and creates the users and sets the passwords from the hashes in that file.

Packer will use the key in `~/.ssh/id_ed25519` to connect up to the system via SSH after install to run the shell provisioner tasks.

Add an ED25519 SSH public key (your system, or the CI/CD runner user) on the `sshkey` line so your system can access via passwordless login.

After building this template VM, we can call Terraform, Ansible, or other scripts to secure / customize it further.