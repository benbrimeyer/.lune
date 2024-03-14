A collection of lune scripts I use for my personal workflows.

## Current capabilities

- hub-install: Install and configure `hub` for use with `review` command
- todo: Create a JIRA ticket
- fb: Create a feature branch from a JIRA ticket (or not)
- review: Create a pull request from the current branch to the default branch (requires hub-install to be ran first)

## Installation

First install lune globally (install guide [here](https://lune-org.github.io/docs/getting-started/1-installation)).

I'd recommend installing `lune` globally via [foreman](https://github.com/Roblox/foreman) or [aftman](https://github.com/LPGhatguy/aftman).

- [Foreman global install instructions (System Tools)](https://github.com/Roblox/foreman?tab=readme-ov-file#system-tools)

I would clone this repository into your global `.lune` directory.

- On MacOSX, this would be your `~/.lune` directory.

## Configuration

Create a `secrets` folder at the root of the directory and add the following files:

### `BRANCH_PREFIX.luau` file with the following content:

We'll use this sting to prefix any feature branches you create. (e.g. `prefix/feature/branch_name`)

This can be any string you want as long as it can be used as part of a branch name. I usually use my name.

```lua
return "branch_prefix" -- no spaces allowed!!
```

### `JIRA_AUTH.luau` file with the following content:

First, you may generate an Atlassian API token [here](https://id.atlassian.com/manage-profile/security/api-tokens).

To convert it to a base64 string, you can use the following command.

```bash
echo -n username@email.com:api_token_string | base64
```

Replace `username@email.com` with the email address you use to log into JIRA and `api_token_string` with the token received from Atlassian.

The output from this command will be your `base64_encoded_string` which you can use in the `JIRA_AUTH.luau` file.

```lua
-- secrets/JIRA_AUTH.luau

return "base64_encoded_string"
```

### `JIRA_URL.luau` file with the following content:

This is likely the domain of your workplace and would read something like `company_name.atlassian.net` when constructed

```lua
-- secrets/JIRA_URL.luau

return "company_name.atlassian.net"
```

## `.gitconfig` setup

To use these scripts as `git` scripts, copy and paste the contents of the [`.gitconfig_alias`](.gitconfig_alias) file into your `.gitconfig` file.

This will allow you to use the lune scripts as `git` commands. For example, `git review` will run the `review` script.
