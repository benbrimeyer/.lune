local process = require("@lune/process")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("./secrets/JIRA_AUTH")
local JIRA_DOMAIN = require("./secrets/JIRA_DOMAIN")

local PR_FLAGS = { "#flagged", "#flag-removal", "#unflagged", "#nonprod"}

local branchResult = process.spawn("git", {"branch", "--show-current"})
local defaultJiraTicket = ""
if branchResult.ok then
    defaultJiraTicket = branchResult.stdout:match("([A-Z]+%-%d+)") or ""
end

print("\nGathering PR details...\n")
local jiraTicket = stdio.prompt("text", "Jira Ticket", defaultJiraTicket)
if #jiraTicket == 0 then
    jiraTicket = "#nojira"
end

local jiraSummary = nil
if #jiraTicket > 0 and jiraTicket ~= "#nojira" then
    local jiraNetRequest = net.request({
        url = `https://{JIRA_DOMAIN}.atlassian.net/rest/api/3/issue/{jiraTicket}`,
        method = "GET",
        headers = {
            Authorization = "Basic " .. JIRA_AUTH,
        },
    })
    if jiraNetRequest.statusCode == 200 then
        local jiraIssue = serde.decode("json", jiraNetRequest.body)
        if jiraIssue and jiraIssue.fields then
            jiraSummary = tostring(jiraIssue.fields.summary)
        end
    end
end

local prFlag = stdio.prompt("select", "Flag", PR_FLAGS)
local prTitle = stdio.prompt("text", "PR Title", jiraSummary)
local problem = stdio.prompt("text", "Problem Statement")
local solution = stdio.prompt("text", "Solution")
local notes = stdio.prompt("text", "Notes (optional)")
local isDraft = stdio.prompt("confirm", "Draft PR?")

local fullPRTitle = `{jiraTicket} {prTitle} {PR_FLAGS[prFlag]}`
local boxWidth = math.max(#fullPRTitle + 4, 30)
stdio.write(`\n{string.rep("─", boxWidth)}┐`)
stdio.write(stdio.style("bold"))
stdio.write(`\n\n{fullPRTitle}\n\n`)
stdio.write(stdio.style("bold"))

stdio.write(`# PROBLEM\n`)
stdio.write(stdio.style("reset"))
stdio.write(`{problem}\n\n`)
stdio.write(stdio.style("bold"))

stdio.write(`# SOLUTION\n`)
stdio.write(stdio.style("reset"))
stdio.write(`{solution}\n\n`)

if #notes > 0 then
    stdio.write(stdio.style("bold"))
    stdio.write(`# NOTES\n`)
    stdio.write(stdio.style("reset"))
    stdio.write(`{notes}\n\n`)
end

stdio.write(`\n{string.rep("─", boxWidth)}┘\n\n`)

local shouldSubmit = stdio.prompt("confirm", "Submit?")
if not shouldSubmit then
    print("\nDid not submit PR. Exiting...\n")
    process.exit(1)
    return
end

print("Pushing to origin...")
local gitPushResult = process.spawn("git", {
	"push",
    "origin",
})
if not gitPushResult.ok then
	print("git push error:", gitPushResult.stderr)
    process.exit(2)
    return
end

local hubArgs = {
	"pull-request",
    "--copy",
    "--message", fullPRTitle,
    "--message", "## Problem",
    "--message", problem .. "\n",
    "--message", "## Solution",
    "--message", solution .. "\n",
}
if #notes > 0 then
    table.insert(hubArgs, "--message")
    table.insert(hubArgs, "## Notes")
    table.insert(hubArgs, "--message")
    table.insert(hubArgs, notes)
end
if isDraft then
    table.insert(hubArgs, "--draft")
end
local hubReviewResult = process.spawn("hub", hubArgs)
if not hubReviewResult.ok then
    print("hub error:", hubReviewResult.stderr)
end
