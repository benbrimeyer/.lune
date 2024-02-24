A collection of lune scripts I use for my personal workflows.

## Configuration

Create a `secrets` folder at the root of the directory and add the following files:

### `JIRA_AUTH.luau` file with the following content:

```lua
-- secrets/JIRA_AUTH.luau

-- Generate with the following:
-- echo -n username@domain.com:api_token_string | base64
return "base64_encoded_string"
```

### `JIRA_DOMAIN.luau` file with the following content:

```lua
-- secrets/JIRA_DOMAIN.luau

-- This is likely the domain of your workplace and would read something like "company_name.atlassian.com" when constructed
return "company_name"
```
