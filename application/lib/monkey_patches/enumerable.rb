module Enumerable
  def group_by_recursive(*props)
    groups = group_by(&props.first)
    if props.count == 1
      groups
    else
      groups.merge(groups) do |_, elements|
        elements.group_by_recursive(*props.drop(1))
      end
    end
  end
end
