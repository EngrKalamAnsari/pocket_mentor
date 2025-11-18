if Rails.env.development? || Rails.env.test?
  require 'bullet'
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.rails_logger = true
  Bullet.add_footer = true
end
