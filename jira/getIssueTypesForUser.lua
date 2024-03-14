--!strict
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("../secrets/JIRA_AUTH")
local JIRA_URL = require("../secrets/JIRA_URL")

type IssueType = {
    name: string,
    id: string,
    selfUrl: string,
}
local ISSUE_TYPES_WE_CARE_ABOUT = {
    "Bug",
    "Task",
    "Story",
}

return function(): { IssueType }?
    local jiraRequest = net.request({
        url = `https://{JIRA_URL}/rest/api/3/issuetype`,
        method = "GET",
        headers = {
            Authorization = "Basic " .. JIRA_AUTH,
        },
    })

    if jiraRequest.statusCode == 200 then
        local response = serde.decode("json", jiraRequest.body)
        local issueTypes = {}
        for _, issueType in response do
            if issueType.scope == nil then
                if table.find(ISSUE_TYPES_WE_CARE_ABOUT, issueType.untranslatedName) ~= nil then
                    table.insert(issueTypes,  {
                        name = issueType.untranslatedName,
                        id = issueType.id,
                        selfUrl = issueType.self,
                    })
                end
            end
        end

        return issueTypes
    end

    return nil
end
