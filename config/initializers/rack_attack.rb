# frozen_string_literal: true

module Rack
  class Attack
    throttle('requests by ip', limit: 100, period: 1.minute, &:ip)

    throttle('cep requests by ip', limit: 30, period: 1.minute) do |request|
      request.ip if request.path.include?('/address') && request.post?
    end

    blocklist('bad actors') do |request|
      Rack::Attack::Allow2Ban.filter(request.ip, maxretry: 200, findtime: 5.minutes, bantime: 1.hour) do
        Rails.cache.read("#{request.ip}:bad_actor")
      end
    end
  end
end

Rack::Attack.throttled_response = lambda do |_env|
  [
    429,
    { 'Content-Type' => 'application/json' },
    [{ error: 'Rate limit exceeded, please try again later.' }.to_json]
  ]
end
