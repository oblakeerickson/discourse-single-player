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

  SiteSetting.rate_limit_create_topic = 0
  SiteSetting.rate_limit_create_post = 0
  SiteSetting.rate_limit_new_user_create_post = 0
  SiteSetting.max_topics_per_day = 90
  SiteSetting.max_topics_in_first_day = 40
  SiteSetting.default_trust_level = 1
  SiteSetting.min_topic_title_length = 1
  SiteSetting.allow_duplicate_topic_titles_category = true

  on(:user_created) do |user|
    username = user.username
    group_name = "g-#{username}"[0..19]
    group = Group.create!({ name: group_name, visibility_level: 4, members_visibility_level: 4 })

    group.add(user)
    GroupActionLogger.new(Discourse.system_user, group).log_add_user_to_group(user)

    cat = { user: Discourse.system_user, name: username, permissions: {}, color: "231F20" }

    # 1 - See Reply Create
    # 2 - See Reply
    cat[:permissions][group_name] = 1

    category = Category.create!(cat)

    # Add Category to Sidebar
    sidebar_category_ids = user.secured_sidebar_category_ids

    if SiteSetting.single_player_enable_subcategories
      sub_categories = {}
      # Create sub-categories
      sub_cat_names = %w[todo note plan]
      sub_cat_names.each do |sub_cat_name|
        sub_cat = {
          user: Discourse.system_user,
          name: sub_cat_name,
          permissions: {
          },
          parent_category_id: category.id,
          allow_unlimited_owner_edits_on_first_post: true,
        }
        sub_cat[:permissions][group_name] = 1
        sub_cat[:color] = "B29DD9" if sub_cat_name == "note"
        sub_cat[:color] = "779ECB" if sub_cat_name == "todo"
        sub_cat[:color] = "77DD77" if sub_cat_name == "plan"

        sub_category = Category.create!(sub_cat)
        sidebar_category_ids << sub_category.id
        sub_categories[sub_cat_name] = sub_category.id
      end

      #Add Subcategories to sidebar
      SidebarSectionLinksUpdater.update_category_section_links(
        user,
        category_ids: sidebar_category_ids,
      )

      # Create Daily Plan Topic
      daily_plan_topic = {
        title: "Daily Plan",
        raw: "Reply to this topic with your plans for the day.",
        category: sub_categories["plan"],
      }
      plan_topic = NewPostManager.new(user, daily_plan_topic).perform
      # Create Weekly Update Topic
      weekly_plan_topic = {
        title: "Weekly Plan",
        raw: "What would you like to accomplish this Week? How did last week go?",
        category: sub_categories["plan"],
      }
      weekly_topic = NewPostManager.new(user, weekly_plan_topic).perform

      if plan_topic.post && weekly_topic.post
        # Create plan sidebar section
        plan_sidebar = { title: "plan", user: user }
        plan_links = [
          { icon: "far-clipboard", name: "daily", value: "/t/#{plan_topic.post.topic_id}/last" },
          { icon: "calendar-alt", name: "weekly", value: "/t/#{weekly_topic.post.topic_id}/last" },
        ]
        SidebarSection.create!(plan_sidebar.merge(sidebar_urls_attributes: plan_links))
      end

      # Create todo sidebar section
      todo_sidebar = { title: "todo", user: user }
      todo_links = [
        { icon: "plus", name: "new", value: "/new-topic?category_id=#{sub_categories["todo"]}" },
        {
          icon: "far-square",
          name: "open",
          value: "/c/#{user.username}/todo/#{sub_categories["todo"]}?status=open",
        },
        {
          icon: "far-check-square",
          name: "closed",
          value: "/c/#{user.username}/todo/#{sub_categories["todo"]}?status=closed",
        },
      ]
      SidebarSection.create!(todo_sidebar.merge(sidebar_urls_attributes: todo_links))

      # Create note sidebar section
      note_sidebar = { title: "note", user: user }
      note_links = [
        { icon: "plus", name: "new", value: "/new-topic?category_id=#{sub_categories["note"]}" },
      ]
      SidebarSection.create!(note_sidebar.merge(sidebar_urls_attributes: note_links))
    end
  end
end
