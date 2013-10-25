module RubyApp
  class App
    attr_reader :id
    alias       :name :id
    attr_reader :uid
    alias       :gid :uid
    attr_reader :domain
    attr_reader :subdomain
    attr_reader :url_path
    attr_reader :script_name

    def initialize(config)
      @config = config
      @id = @config['id']
      if @config['user']
        @uid = @config['user']['uid']
      end
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

    def username
      unless uid.nil?
        underscored_name
      end
    end
    alias :group_name :username

    def full_domain
      RubyApp::Domain.concat subdomain, domain
    end

    def url?
      !!domain
    end

    def url_path
      @url_path || '/'
    end

    def url_path?
      @url_path.to_s =~ /\w/
    end

    def url_parent_path
      parts = url_path.split('/')
      parent_path = parts[0...parts.length-1].join '/'
      parent_path == '' ? '/' : parent_path
    end

    def url_parent_path?
      url_parent_path != '/'
    end

    private

    def underscored_name
      name.downcase.gsub /[^a-z0-9_]/, '_'
    end
  end
end