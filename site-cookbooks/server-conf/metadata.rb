name             'server-conf'
maintainer       'surenot'
maintainer_email 'no@spam.com'
license          'All rights reserved'
description      'Installs/Configures server-conf'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends "sudo"
depends "user"
depends "openssh"
depends "docker"
