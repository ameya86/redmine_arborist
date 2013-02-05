require File.expand_path('../../test_helper', __FILE__)

class RebuilderTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :users, :trackers, :issue_statuses, :enumerations, :projects_trackers

  # 初期設定
  def setup
    create_dummy_issues
  end

  def test_issue_rebuild
    issues = Issue.find_all_by_root_id(@root_id)
    assert_not_equal @orig_lft, issues.collect(&:lft)
    assert_not_equal @orig_rgt, issues.collect(&:rgt)

    RedmineArborist::Rebuilder.rebuild!(Issue, @root_id)

    # 正常な並びに戻ったことを確認する
    issues = Issue.find_all_by_root_id(@root_id)
    assert_equal @orig_lft, issues.collect(&:lft)
    assert_equal @orig_rgt, issues.collect(&:rgt)
  end

  # テスト用のチケットを作成する
  def create_dummy_issues
    template = {:subject => 'dummy', :project_id => 1, :author_id => User.anonymous.id, :priority_id => 4, :tracker_id => 1}
    root = Issue.new(template)
    root.save!

    child1 = Issue.new(template)
    child1.parent_issue_id = root.id
    child1.save!

    child2 = Issue.new(template)
    child2.parent_issue_id = root.id
    child2.save!

    child1_1 = Issue.new(template)
    child1_1.parent_issue_id = child1.id
    child1_1.save!

    child1_2 = Issue.new(template)
    child1_2.parent_issue_id = child1.id
    child1_2.save!

    child1_3 = Issue.new(template)
    child1_3.parent_issue_id = child1.id
    child1_3.save!

    child2_1 = Issue.new(template)
    child2_1.parent_issue_id = child2.id
    child2_1.save!

    child2_2 = Issue.new(template)
    child2_2.parent_issue_id = child2.id
    child2_2.save!

    issues = Issue.find_all_by_root_id(root.id)
    @orig_lft = issues.collect(&:lft)
    @orig_rgt = issues.collect(&:rgt)

    # lft、rgtをずらす
    child1_2.reload
    child1_2[:lft] = 5
    child1_2[:rgt] = 1
    child1_2.save!(:validate => false)

    child2_2.reload
    child2_2[:lft] = 12
    child2_2[:rgt] = 3
    child2_2.save!(:validate => false)

    @root_id = root.id.to_s
  end
end
