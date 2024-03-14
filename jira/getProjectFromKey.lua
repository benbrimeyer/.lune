--!strict
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("../secrets/JIRA_AUTH")
local JIRA_URL = require("../secrets/JIRA_URL")

type Project = {
    key: string,
    id: string,
    selfUrl: string,
}

return function(projectKey: string): Project?
    local jiraRequest = net.request({
        url = `https://{JIRA_URL}/rest/api/3/project/search?keys={projectKey}`,
        method = "GET",
        headers = {
            Authorization = "Basic " .. JIRA_AUTH,
        },
    })

    if jiraRequest.statusCode == 200 then
        local response = serde.decode("json", jiraRequest.body)
        if response.total == 1 then
            local projectResponse = response.values[1]
            return {
                key = projectResponse.key,
                id = projectResponse.id,
                selfUrl = projectResponse.self,
            }
        end

        return nil
    end

    return nil
end
