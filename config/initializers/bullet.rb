if Rails.env.local?
  require 'bullet'
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.rails_logger = true
  Bullet.add_footer = true
end
