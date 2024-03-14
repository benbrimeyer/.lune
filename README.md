A collection of lune scripts I use for my personal workflows.

## Current capabilities

- self-secrets: Fill in the `secrets` folder with the necessary files
- hub-install: Install and configure `hub` for use with `review` command
- todo: Create a JIRA ticket
- fb: Create a feature branch from a JIRA ticket (or not)
- review: Create a pull request from the current branch to the default branch (requires hub-install to be ran first)

### Demo

I can create a JIRA ticket to do later with the following command after doing the full setup:

```bash
git todo "Create a lune script to automate JIRA ticket creation"
```

I can then create a feature branch with the following command:

```bash
git fb
```

When I'm done with the branch, I can create a review with the following command:

```bash
git review
```

## Installation

First install lune globally (install guide [here](https://lune-org.github.io/docs/getting-started/1-installation)).

I'd recommend installing `lune` globally via [foreman](https://github.com/Roblox/foreman) or [aftman](https://github.com/LPGhatguy/aftman).

- [Foreman global install instructions (System Tools)](https://github.com/Roblox/foreman?tab=readme-ov-file#system-tools)

Or if you want to use brew:

```bash
brew install lune
```

I would clone this repository into your global `.lune` directory. This will allow you to use these scripts from any directory on your machine.

- On MacOSX, this would be your `~/.lune` directory.
  - `cd ~` then `git clone https://github.com/benbrimeyer/.lune-scripts .lune`

### Configuration

Once `lune` is installed, run `lune run self-secrets` to fill in the `secrets` folder with the necessary files.

## `.gitconfig` setup

To use these scripts as `git` scripts, copy and paste the contents of the [`.gitconfig_alias`](.gitconfig_alias) file into your `.gitconfig` file.

This will allow you to use the lune scripts as `git` commands. For example, `git review` will run the `review` script.
