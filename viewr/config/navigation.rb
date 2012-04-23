SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = "active"
  navigation.items do |primary|
    primary.dom_class = "nav nav-list"
    primary.item :overview, '<i class="icon-eye-open"></i> Overview', '/admin'
    primary.item :post, '<i class="icon-envelope"></i> Post Message', '/admin/post'
    primary.item :feeds, '<i class="icon-retweet"></i> Feeds', '/admin/feeds', :if => Proc.new { current_user.is_superadmin }
    primary.item :general_settings, '<i class="icon-cog"></i> General Settings', '#', :if => Proc.new { current_user.is_superadmin }
    primary.item :user_management, '<i class="icon-user"></i> User Management', usrs_path, :if => Proc.new { current_user.is_superadmin }
    primary.item :sign_out, 'Sign Out', destroy_user_session_path, :method => :delete
  end
end
