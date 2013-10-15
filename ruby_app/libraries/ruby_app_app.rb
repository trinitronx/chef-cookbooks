module RubyApp
  class App
    attr_reader :id
    alias :name :id
    attr_reader :domain
    attr_reader :subdomain
    attr_reader :url_path
    attr_reader :script_name

    def initialize(config)
      @config = config
      @id = @config['id']
      if @config['url']
        @domain = config['url']['domain']
        @subdomain = config['url']['subdomain']
        @url_path = config['url']['path']
        if @config.has_key? 'script_name'
          @script_name = @config['script_name']
        else
          @script_name = @config['url']['path']
        end
      end
    end

    def full_domain
      RubyApp::Domain.concat subdomain, domain
    end

    def url_path
      @url_path || '/'
    end

    def url_path?
      @url_path.to_s =~ /\w/
    end

    def username
      name.downcase.gsub /[^a-z0-9_]/, '_'
    end
  end
end