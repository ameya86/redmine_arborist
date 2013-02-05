module RedmineArborist
  module Rebuilder
    # 親子関係を修復する
    def rebuild!(klass, target_id)
      table_name = klass.table_name
      target = klass.find(target_id)

      ActiveRecord::Base.transaction do
        # 根となるアイテム
        root = klass.find(target.root_id)

        # 対象のアイテムの属するツリーのアイテムを取得する（ロックあり）
        families = klass.find(:all, :lock => true, :conditions => ["root_id = ?", root.id])
        familie_ids = families.collect(&:id)

        # ツリーが異なるが親アイテムがツリーのアイテムを指しているアイテムを取得する
        other_families = klass.find(:all, :conditions => ["parent_id in (?)", familie_ids])

        # 親アイテムを元に再構築する
        nested_list = nesting(families, [], root)
        nested_item_update(nested_list)

        # 保存する（バリデーション無視）
        families.each{|i| i.save!(:validate => false) }

        # エラーがなければ真を返す
        return true
      end # transaction

      # トランザクションが解除されたら偽を返す
      return false
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

    # アイテムの配置に応じて、lft、rgtを更新する
    def nested_item_update(nested_list)
      left_list = []
      nested_list.each_with_index do |item, index|
        if !left_list.include?(item.id)
          # 1つ目はlftを更新
          item[:lft] = index + 1
          left_list << item.id
        else # 2つ目はrgtを更新
          item[:rgt] = index + 1
        end
      end

      return nested_list
    end
    module_function :nested_item_update

    # 子アイテムを探す
    def children(families, item)
      return families.select{|i| i.parent_id == item.id }
    end
    module_function :children
  end
end
