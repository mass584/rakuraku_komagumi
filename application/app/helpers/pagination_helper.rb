module PaginationHelper
  def max_page(total_record:, page_size:)
    if page_size.instance_of?(Integer)
      (1 + (total_record - 1) / page_size)
    else
      (1 + (total_record - 1) / 25)
    end
  end

  def pagination_query_params(page:, page_size:, keyword:)
    query_params = {}
    query_params.merge!({ page: page }) if page.instance_of?(Integer)
    query_params.merge!({ page_size: page_size }) if page_size.instance_of?(Integer)
    query_params.merge!({ keyword: keyword }) if keyword.instance_of?(String)
    query_params
  end
end
