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
      @config ||= @full_config['environments']['all'].merge(@full_config['environments'][environment])
    end
  end
end