local net = require("@lune/net")
local serde = require("@lune/serde")

local JIRA_AUTH = require("../secrets/JIRA_AUTH")
local JIRA_DOMAIN = require("../secrets/JIRA_DOMAIN")

return function(selectedTicketKey: string): boolean
    local jiraGetWorkflowRequest = net.request({
        url = `https://{JIRA_DOMAIN}.atlassian.net/rest/api/3/issue/{selectedTicketKey}/transitions`,
        method = "GET",
        headers = {
            Authorization = "Basic " .. JIRA_AUTH,
        },
    })
    if jiraGetWorkflowRequest.statusCode == 200 then
        local jiraTransitions = serde.decode("json", jiraGetWorkflowRequest.body)
        -- find Open transition
        local transitionId
        for _, transition in jiraTransitions.transitions do
            if transition.name == "Open" then
                transitionId = transition.id
               break
            end
        end

        if transitionId then
            local jiraTransitionRequest = net.request({
                url = `https://{JIRA_DOMAIN}.atlassian.net/rest/api/3/issue/{selectedTicketKey}/transitions`,
                method = "POST",
                headers = {
                    Authorization = "Basic " .. JIRA_AUTH,
                    ["Content-Type"] = "application/json",
                },
                body = serde.encode("json", {
                    transition = {
                        id = transitionId,
                    },
                }),
            })
            if jiraTransitionRequest.statusCode == 204 then
                print("Ticket transitioned to Open")
                return true
            else
                print("Failed to transition ticket to Open")
            end
        else
            print("Could not find transition:", transitionId)
        end
    else
        print("Failed to get transitions")
    end

    return false
end
