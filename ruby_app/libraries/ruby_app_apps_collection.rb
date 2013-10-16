module RubyApp
  class AppsCollection
    include Enumerable

    def initialize(apps = [])
      @apps = apps
    end

    def each(&block)
      @apps.each(&block)
    end

    def <<(app)
      @apps << app
    end

    def domains
      [].tap do |domains|
        @apps.group_by(&:full_domain).each do |domain, apps|
          domains << RubyApp::Domain.new(apps.first.domain, apps, subdomain: apps.first.subdomain)
        end
      end
    end
  end
end