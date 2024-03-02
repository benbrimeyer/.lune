--!strict
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("./secrets/JIRA_AUTH")
local JIRA_DOMAIN = require("./secrets/JIRA_DOMAIN")

local getIssueTypesForUser = require("./jira/getIssueTypesForUser")
local getProjectFromKey = require("./jira/getProjectFromKey")

local function findUntilFlag(args: { string }): string?
    local result = {}
    for i, arg in args do
        if args[i]:sub(1, 1) == "-" then
            break
        else
            table.insert(result, arg)
        end
    end

    return table.concat(result, " ")
end

local function findFlag(args: { string }, flag: string): string?
    for i, arg in args do
        if arg == flag then
            local result = {}
            -- join args
            for j = i + 1, #args do
                if args[j]:sub(1, 1) == "-" then
                    break
                end

                table.insert(result, args[j])
            end

            return table.concat(result, " ")
        end
    end
    return nil
end

local issueTypes = getIssueTypesForUser()

local issueTypesByString = {}
for _, issueType in issueTypes do
    table.insert(issueTypesByString, issueType.name)
end

local projectKey = stdio.prompt("text", "Project Key")
local project = getProjectFromKey(projectKey)
if project == nil then
    print("\nProject not found. Exiting...\n")
    return
end

local selectedIssueTypeIndex = stdio.prompt("select", "Issue type", issueTypesByString)
local selectedIssueType = issueTypes[selectedIssueTypeIndex]

local summary = findUntilFlag(process.args) or stdio.prompt("text", "Summary")
local description = findFlag(process.args, "--description") or nil

local jiraNetRequest = net.request({
    url = `https://{JIRA_DOMAIN}.atlassian.net/rest/api/3/issue`,
    method = "POST",
    headers = {
        Authorization = "Basic " .. JIRA_AUTH,
        Accept = "application/json",
        ["Content-Type"] = "application/json"
    },
    body = serde.encode("json", {
        fields = {
            summary = summary,
            issuetype = {
                id = selectedIssueType.id
            },
            project = {
                id = project.id,
            },
            description = if description then {
                content = {
                {
                    content= {
                    {
                        text = description,
                        type = "text"
                    }
                    },
                    type = "paragraph"
                }
                },
                type = "doc",
                version = 1
            } else nil,
        },
    }),
})

if jiraNetRequest.statusCode == 201 then
    local jiraIssue = serde.decode("json", jiraNetRequest.body)
    print(`Issued created: https://{JIRA_DOMAIN}.atlassian.net/browse/{jiraIssue.key}`)
    return jiraIssue.key
end
