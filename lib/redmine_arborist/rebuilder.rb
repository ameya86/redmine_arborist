module RedmineArborist
  module Rebuilder
    # 親子関係を修復する
    def rebuild!(klass, target_id)
      table_name = klass.table_name
      target = klass.find(target_id)

      # 根となるアイテム
      root = klass.find(target.root_id)
      #root = klass.find(:first, ["id in (select root_id from #{table_name} where id = ?)", target_id.to_i])

      # 対象のチケットの属するツリーのアイテムを取得する
      families = klass.find(:all, :conditions => ["root_id = ?", root.id])
      familie_ids = families.collect(&:id)

      # ツリーが異なるが親アイテムがツリーのアイテムを指しているアイテムを取得する
      other_families = klass.find(:all, :conditions => ["parent_id in (?)", familie_ids])

      # 親アイテムを元に再構築する
      nested_list = nesting(families, [], root)

      left_list = []
      nested_list.each_with_index do |item, index|
        if !left_list.include?(item.id)
          item[:lft] = index + 1
          left_list << item.id
        else
          item[:rgt] = index + 1
        end
      end

      # 保存する（バリデーション無視）
      families.each{|i| i.save(:validate => false) }

      return true
    end
    module_function :rebuild!

    # listにfamiliesのアイテムを親子順に入れていく
    def nesting(families, list, item)
      list << item
      children(families, item).each do |item2|
        list = nesting(families, list, item2)
      end
      list << item
      return list
    end
    module_function :nesting

    # 子アイテムを探す
    def children(families, item)
      return families.select{|i| i.parent_id == item.id }
    end
    module_function :children
  end
end
