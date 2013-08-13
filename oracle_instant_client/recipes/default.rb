class Chef::Recipe
  include OracleInstantClientHelpers
end

class Chef::Resource
  include OracleInstantClientHelpers
end

package 'unzip'
package 'libaio-dev'

directory base_dir do
  action :create
end

node['oracle_instant_client']['files'].each do |name, url|
  remote_file File.join(base_dir, "instantclient-#{name}.zip") do
    source url
    action :create_if_missing
  end
end

unless lib_path
  bash 'unzip_files' do
    cwd base_dir
    code 'unzip -n ./instantclient-\*.zip'
  end
end

# These resources are ruby_blocks because the standard Chef resources
# are evaluated before the run list has been excetude. Which means the
# .zip files haven't been unzipped and lib_path is nil.
# ruby_block resources, however, are run at execute time.
# Once we've upgraded to Chef 11.6 lazy attribute evaluation could probably
# be used instead.
# http://docs.opscode.com/release_notes.html#lazy-attribute-evaluation
ruby_block 'link_libclntsh.so' do
  block do
    unless File.exists? File.join(lib_path, 'libclntsh.so')
      Dir.chdir lib_path
      File.symlink libclntsh_file, 'libclntsh.so'
    end
  end
end

ruby_block 'set_environment_variables' do
  block do
    path = '/etc/profile.d/oracle_instant_client.sh'

    unless File.exists? path
      File.open(path, 'w') do|file|
        file.write("export LD_LIBRARY_PATH=#{lib_path}")
      end
    end
  end
end