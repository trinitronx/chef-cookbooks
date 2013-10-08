module RubyAppDomainHelpers
  def concat_domain(*parts)
    parts.compact.join('.')
  end

  def username_for(app_name)
    app_name.downcase.gsub /[^a-z0-9_]/, '_'
  end
end