module RubyApp
  class Config
    def initialize(full_config, node)
      @node = node

      @full_config = full_config
      @full_config['environments'] ||= {}
      @full_config['environments']['all'] ||= {}
      @full_config['environments'][environment] ||= {}
      @full_config['nodes'] ||= {}
      @full_config['nodes'][fqdn] ||= {}
    end

    def files
      Hash[files_hash.map { |filename, hash| [filename, YAML::dump(hash)] }]
    end

    def [](key)
      config[key]
    end

    private

    attr_reader :node

    def environment
      node.chef_environment
    end

    def fqdn
      node.fqdn
    end

    def files_hash
      config['files'] || {}
    end

    # Config hashes that apply to this node
    def matched_configs
      [@full_config['environments'][environment], @full_config['nodes'][fqdn]]
    end

    def config
      return @config unless @config.nil?
      @config = @full_config['environments']['all']

      matched_configs.each do |matched_config|

        # Make sure things like ['all']['files'] gets merged with [environment]['files']
        # and not overwritten by it.
        matched_config.each do |key, value|
          if @config.has_key?(key) && @config[key].is_a?(Hash)
            @config[key].merge! value
          else
            @config[key] = value
          end
        end
      end

      @config
    end
  end
end