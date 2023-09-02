# frozen_string_literal: true

# name: discourse-single-player
# about: All new users will only have access to their own private category and groupx
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
    puts "USER CREATED !!!!!!!!!!!!!"
    puts "USERNAME: #{user.username}"
    puts "INSPECT: "
    puts user.inspect

    username = user.username
    group_name = "g-#{username}"[0..19]
    g = Group.create!({
      name: group_name,
      visibility_level: 4,
      members_visibility_level: 4,
    })

    puts "GROUP: #{g.name}"
    puts g.inspect

    # can see - Group owners
    # can see members - Group owners
  end
end
