maintainer       "Biola University"
maintainer_email "jared.king@biola.edu"
license          "Apache 2.0"
description      "Manages MySQL databases, users, and backups using data bags and Opscode's database cookbook"
version          "0.0.1"
supports 				 "ubuntu", "12.04"
%w{ build-essential database mysql }.each do |cb|
  depends cb
end