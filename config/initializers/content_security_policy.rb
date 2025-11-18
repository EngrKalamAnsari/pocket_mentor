# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # Default: allow same-origin and secure (https) resources
    policy.default_src :self, :https

    # Allow fonts and images from same-origin, https and data URIs
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data

    # Don't allow plugins/objects
    policy.object_src  :none

    # Scripts and styles: allow same-origin and secure CDNs used by the app.
    # The app uses Bootstrap from jsDelivr in `app/views/layouts/application.html.erb`.
    policy.script_src  :self, :https, 'https://cdn.jsdelivr.net'
    policy.style_src   :self, :https, 'https://cdn.jsdelivr.net'

    # You can enable a report endpoint to collect violation reports from browsers
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate nonces for inline scripts/styles when needed (Importmap, inline tags)
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Start in report-only mode so you can see violations without blocking resources.
  config.content_security_policy_report_only = true
end
