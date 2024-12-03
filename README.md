# Ada's website

Wherein I set up a little website, and learn a bunch of stuff as I go.

## What it's made of

### Inside the box

- [Wagtail](https://wagtail.org) (on [Django](https://www.djangoproject.com)) is the web framework
<!-- - [Tailwind CSS](https://tailwindcss.com) for styling -->

### Holding things together

- [UV](https://github.com/astral-sh/uv) for all Python project management
- [Just](https://just.systems) as a command runner
- [OpenTofu](https://opentofu.org) for DevOps
- [Postgres](https://www.postgresql.org) for the database
- [Docker](https://www.docker.com) for local development

## Quickstart

### Requirements

- On a Mac:

```shell
brew install colima docker
```

### Run a development server

```shell
just tofu workspace select dev
just tofu apply
```

This will spin up a box on DigitalOcean using the settings defined in
[infra/variables.tf](infra/variables.tf), and create a DNS A record at
(workspace).for.(tld), (i.e. dev.for.hpk.io) pointing to the box. The variables
`do_token` and `ssh_fingerprint` should be defined in
[infra/secrets.tfvars](infra/secrets.tfvars). Workspace-specific variables are
defined in infra/envs/(workspace).tfvars; e.g.
[infra/envs/dev.tfvars](infra/envs/dev.tfvars) defines the 'tags' list for the
box as `[development]` and sets `cloud_init_config` to point to the
[cloud-init](https://cloud-init.io) script
[config/cloud-init-dev.yml](config/cloud-init-dev.yml).

The development cloud-init script will:

- Install the system packages [`just`](https://just.systems), [`zsh`](https://www.zsh.org),
  [`gunicorn`](https://gunicorn.org), and `tree`
- Create a 'wagtail' user, with UID 1500
- Create the 'ada' user, and:
  - install their SSH public keys,
  - install their dotfiles,
  - add them to the 'sudo' and 'wagtail' groups
- Install [Node](http://nodejs.org) on the system, from the `TF_VAR_NODE_VERSION`
  defined in [.env](.env)
- Checkout this repository into `/app`, setting the owner and group to 'wagtail'.
