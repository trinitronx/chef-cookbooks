module OracleInstantClientHelpers
  def base_dir
    node['oracle_instant_client']['base_dir']
  end

  def lib_path
    Dir[File.join(base_dir, 'instantclient*')].find { |f| File.directory?(f) }
  end

  def libclntsh_file
    Dir.chdir lib_path
    Dir['libclntsh.so*'].find { |f| File.file?(f) && !File.symlink?(f) }
  end
end