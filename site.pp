node default {
# Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git, lsys, lsys::pxe::tftp, lsys::pxe::dhcp
}

node 'node01.example.com', 'node02.example.com' {
# Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git
}
