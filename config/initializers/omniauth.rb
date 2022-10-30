Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, '
    150255389954-81g3hqah6me6t8mpsf3sb09qrp1seg4j.apps.googleusercontent.com', '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
    ', scope: 'userinfo.profile,youtube'
end