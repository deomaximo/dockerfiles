package docker.authz

# Provide some contextual data for the authorization plugin
users = {
    "baxter": {"role": "serviceDesk"},
    "bolt": {"role": "netAdmin"},
    "rackham": {"role": "fullAdmin"},
}


# Define the default value in the event that rules with the same name
# are undefined
default allow = false

# Rule that allows a user with 'fullAdmin' role to invoke all Engine
# API calls
allow {
    user_id = input.User
    users[user_id].role = "fullAdmin"
}


# Rule that limits a user with the 'serviceDesk' role, to only invoke
# API calls using the GET method (i.e. read-only)
allow {
    user_id = input.User
    users[user_id].role = "serviceDesk"
    input.Method = "GET"
}


# Rule that allows a ussr with the 'netAdmin' role, to invoke API calls
# on network objects only, provided the method is not DELETE
allow {
    user_id = input.User
    users[user_id].role = "netAdmin"
    contains(input.Path, "/networks")
    input.Method != "DELETE"
}
