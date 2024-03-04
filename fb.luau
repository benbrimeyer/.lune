local process = require("@lune/process")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("./secrets/JIRA_AUTH")
local JIRA_DOMAIN = require("./secrets/JIRA_DOMAIN")

local transitionIssueToOpen = require("./jira/transitionIssueToOpen")

local GREEN_SQUARE = utf8.char(0x1F7E9)
local BUG_EMOJI = utf8.char(0x1F41E)


print("\nSearching assigned tickets...\n")
local maxResults = 9
local jql_query = `assignee in (currentUser()) AND issuetype in (Story, Bug) AND status not in (Closed, Done, "Ready to Deploy", "In Testing") AND sprint in openSprints()`
local jiraNetRequest = net.request({
    url = `https://{JIRA_DOMAIN}.atlassian.net/rest/api/3/search?jql={jql_query}&maxResults={maxResults}&fields=summary,issuetype,key,status`,
    method = "GET",
    headers = {
        Authorization = "Basic " .. JIRA_AUTH,
    },
})

if jiraNetRequest.statusCode == 200 then
    local jiraIssues = serde.decode("json", jiraNetRequest.body)

    local jiraTickets = {}
    local formattedTickets = { "Other..." }
    for _, jiraIssue in jiraIssues.issues do
        table.insert(jiraTickets, 1, { key = jiraIssue.key, summary = jiraIssue.fields.summary, status = jiraIssue.fields.status.name })
        local issueTypeEmoji = if jiraIssue.fields.issuetype.name == "Story" then GREEN_SQUARE else BUG_EMOJI
        table.insert(formattedTickets, 1, `{issueTypeEmoji} {jiraIssue.key} - {jiraIssue.fields.summary}`)
    end

    local ticketIndex = stdio.prompt("select", "Select issue...", formattedTickets)
    local selectedTicketStatus = if jiraTickets[ticketIndex] then jiraTickets[ticketIndex].status else nil
    local selectedTicketKey = if jiraTickets[ticketIndex] then jiraTickets[ticketIndex].key else nil
    if selectedTicketKey == nil then
        selectedTicketKey = stdio.prompt("text", "Enter issue key...")
    end

    -- detour for Submitted tickets
    if selectedTicketStatus == "Submitted" then
        if stdio.prompt("confirm", "This ticket is not opened. Would you like to transition it to Open?") then
            print("Attempting to transition ticket to Open...")
            if not transitionIssueToOpen(selectedTicketKey) then
                if not stdio.prompt("confirm", "Failed to transition issue. Continue anyway?") then
                    print("Exiting without creating feature branch...")
                    process.exit(1)
                    return
                end
            end
        end
    end

    local subtitle = if process.args[1] then process.args[1] else stdio.prompt("text", "Enter branch subtitle (optional)...", "init")
    local branchName = `bbrimeyer/fb/{selectedTicketKey}/{subtitle}`

    local gitLatestResult = process.spawn("git", {
        "latest",
    })
    if not gitLatestResult.ok then
        print("Error: ", gitLatestResult.stderr)
        print("Failed to get latest branch. Exiting...")
        process.exit(1)
        return
    end

    local gitCheckoutResult = process.spawn("git", {
        "checkout",
        "-b",
        branchName,
    })
    if not gitCheckoutResult.ok then
        print("Error: ", gitCheckoutResult.stderr)
        print("Failed to create branch. Exiting...")
        process.exit(1)
    end

    print(`\nChecked out "{branchName}"\n`)
end
