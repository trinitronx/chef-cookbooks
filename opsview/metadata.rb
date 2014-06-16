name             'opsview'
maintainer       'Biola University'
maintainer_email 'jared.king@biola.edu'
license          'Apache 2.0'
description      'Installs and configures Opsview Core'
version          '1.3.0'
%w{ apt chef-vault mysql vmware yum }.each do |cb|
  depends cb
end