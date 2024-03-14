local process = require("@lune/process")
local stdio = require("@lune/stdio")

local getHomeDir = require("./getHomeDir")

local boxWidth = 80
local function generateHubConfig(authInfo)
    stdio.write(`\n{string.rep("─", boxWidth)}┐\n`)
    for host, auth in authInfo do
        stdio.write(`{host}\n`)
        stdio.write(`- user: {auth.user}\n`)
        stdio.write(`  oauth_token: {auth.token}\n`)
        stdio.write(`  protocol: "https"\n`)
    end
    stdio.write(`\n{string.rep("─", boxWidth)}┘\n\n`)
end

local function openHubConfig(authInfo)
    local openHubConfigProcess = process.spawn("open", { ".config/hub" }, {
        cwd = getHomeDir(),
        stdio = "inherit",
    })
    if not openHubConfigProcess.ok then
        print("Error: ", openHubConfigProcess.stderr)
        print("Failed to open hub configuration file. Exiting...")
        process.exit(1)
    end

    print("Opened hub configuration file")
end

local function getHubAuthInfo(url: string)
    local user = stdio.prompt("text", `Enter your username for {url}...`)
    local token = stdio.prompt("text", `Enter your token for {url}...`)
    return { user = user, token = token }
end

-- installs hub via brew
local function installHub()
    print("Installing hub...")
    local installHubProcess = process.spawn("brew", { "install", "hub" }, {
        stdio = "inherit",
    })
    if not installHubProcess.ok then
        print("Error: ", installHubProcess.stderr)
        print("Failed to install hub. Exiting...")
        process.exit(1)
    end

    print("Hub installed")
    local authInfo = {
        ["github.com"] = getHubAuthInfo("github.com"),
    }

    if stdio.prompt("confirm", "Would you like to add an entry for a private GitHub instance (such as GitHub Enterprise)?") then
        local gitHubHost = stdio.prompt("text", "Enter the hostname of your private GitHub instance (e.g. github.example.com)")
        local gitConfigProcess = process.spawn("git", { "config", "--global", "--add", "hub.host", gitHubHost }, {
            stdio = "inherit",
        })
        if not gitConfigProcess.ok then
            print("Error: ", gitConfigProcess.stderr)
            print("Failed to add GitHub host. Exiting...")
            process.exit(1)
        end

        print(`Added GitHub host "{gitHubHost}" to git config`)
        authInfo[gitHubHost] = getHubAuthInfo(gitHubHost)
    end

    print("\nYou may need to provide GitHub tokens to hub.")
    print("Copy the text below and paste it into your hub configuration file:")
    generateHubConfig(authInfo)
    if stdio.prompt("confirm", "Press Y to attempt to open the hub configuration file.") then
        openHubConfig(authInfo)
    end
end

installHub()
