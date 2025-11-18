# frozen_string_literal: true

class Rack::Attack
  # Throttle requests to 5 requests per 5 seconds per IP
  throttle('req/ip', limit: 5, period: 5.seconds) do |req|
    req.ip
  end

  # Block & log IPs that are throttled more than a threshold in a short window
  # Here we use a safelist/whitelist for local requests
  safelist('allow-localhost') do |req|
    # Allow localhost, internal health checks, etc.
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  # Custom response for throttled/banned clients
  self.throttled_response = lambda do |env|
    now = Time.now.utc
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [ 429, { 'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s }, [{ error: 'Throttle limit reached. Try again later.' }.to_json]]
  end
end
