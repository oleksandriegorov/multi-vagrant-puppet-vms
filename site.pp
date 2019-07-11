node default {
# Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git, lsys, lsys::pxe::tftp

  lsys::dhcp::group { 'pxe_c100':
    comment      => 'PXE c100',
    pxe_settings => true,
    host         => {
      'rpmb'       => {
        mac       => '00:50:56:8E:5B:30',
        ip        => '216.55.156.40',
        host_name => 'rpmb.carrierzone.com',
      },
      'bsys'       => {
        mac       => '00:50:56:A5:E9:81',
        ip        => '216.55.156.41',
        host_name => 'bsys.carrierzone.com',
      },
      'web170c100' => {
        mac       => '00:50:56:8E:23:B6',
        ip        => '216.55.156.42',
        host_name => 'web170c100.carrierzone.com',
      }
    }
  }
}

node 'node01.example.com', 'node02.example.com' {
# Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git
}
