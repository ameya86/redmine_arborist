module RedmineArborist
  class Hook < Redmine::Hook::ViewListener
    render_on :view_issues_context_menu_end, :partial => 'arborists/issues_context_menu_end'
  end
end
