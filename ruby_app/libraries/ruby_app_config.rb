module RubyApp
  class Config
    attr_reader :environment

    def initialize(full_config, environment)
      @environment = environment

      @full_config = full_config
      @full_config['environments'] ||= {}
      @full_config['environments']['all'] ||= {}
      @full_config['environments'][environment] ||= {}
    end

    def files
      Hash[config['files'].map { |filename, hash| [filename, YAML::dump(hash)] }]
    end

    def [](key)
      config[key]
    end

    private

    def config
      return @config unless @config.nil?
      @config = @full_config['environments']['all']

      # Make sure things like ['all']['files'] gets merged with [environment]['files']
      # and not overwritten by it.
      @full_config['environments'][environment].each do |key, value|
        if @config.has_key?(key) && @config[key].is_a?(Hash)
          @config[key].merge! value
        else
          @config[key] = value
        end
      end
      @config
    end
  end
end