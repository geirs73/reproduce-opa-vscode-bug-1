package bundle1

import rego.v1

users := {"jkelly", "jbond"}

allow if {
	some user in users
	user == "jkelly"
}

found if {
	some user in users
	input.user == user
}
