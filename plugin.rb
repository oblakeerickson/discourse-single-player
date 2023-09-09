# frozen_string_literal: true

# name: discourse-single-player
# about: New users will get their own private category and group
# version: 0.0.1
# authors: Blake Erickson
# url: https://github.com/oblakeerickson/discourse-single-player
# required_version: 2.7.0

enabled_site_setting :single_player_enabled

module ::SinglePlayerModule
  SINGLE_PLAYER = "discourse-single-player"
end

require_relative "lib/single_player_module/engine"

after_initialize do
  # Code which should run after Rails has finished booting
  DiscourseEvent.on(:user_created) do |user|
    username = user.username
    group_name = "g-#{username}"[0..19]
    group = Group.create!({
      name: group_name,
      visibility_level: 4,
      members_visibility_level: 4,
    })

    group.add(user)
    GroupActionLogger.new(Discourse.system_user, group).log_add_user_to_group(user)

    cat = {
      user: Discourse.system_user,
      name: username,
      permissions: {}
    }

    # 1 - See Reply Create
    # 2 - See Reply
    cat[:permissions][group_name] = 1

    category = Category.create!(cat)

    # Add Category to Sidebar
  end
end
