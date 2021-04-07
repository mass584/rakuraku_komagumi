module PagerHelper
  def max_page(total_record, page_size)
    (1 + (total_record - 1) / page_size).to_i
  end
end
