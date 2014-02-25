module RubyApp
  class Domain
    attr_reader :domain
    attr_reader :subdomain
    attr_reader :apps

    def initialize(domain, apps, options = {})
      @domain = domain
      @apps = Array(apps)
      @subdomain = options[:subdomain]
    end

    def for_environment(environment, options = {})
      domain_parts = if environment =~ /^prod(uction)?$/
        [subdomain, domain]
      else
        [subdomain, environment, domain]
      end

      domain_full = RubyApp::Domain.concat(domain_parts)
      domain_full.gsub! '*', 'wildcard' if options[:safe]

      domain_full
    end

    def for_host(hostname)
      RubyApp::Domain.concat(subdomain, hostname)
    end

    # Apps not hosted at the root of the domain
    def non_root_apps
      apps.select(&:url_path?)
    end

    def non_root_apps?
      non_root_apps.any?
    end

    def self.concat(*domain_parts)
      domain_parts.flatten.compact.join('.')
    end
  end
end