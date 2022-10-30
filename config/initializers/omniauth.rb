Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV['150255389954-81g3hqah6me6t8mpsf3sb09qrp1seg4j.apps.googleusercontent.com'], ENV['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'], scope: 'userinfo.profile,youtube'
end

OmniAuth.config.on_failure do |env|
    error_type = env['omniauth.error.type']
    new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{error_type}"
    [301, {'Location' => new_path, 'Content-Type' => 'text/html'}, []]
  end