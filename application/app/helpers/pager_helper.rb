module PagerHelper
  def min_page
    1
  end

  def max_page(total_record, record_per_page)
    (1 + (total_record - 1) / record_per_page).to_i
  end

  def effective_page(total_record, record_per_page, current_page)
    if min_page > current_page
      min_page
    elsif max_page(total_record, record_per_page) < current_page
      max_page(total_record, record_per_page)
    else
      current_page
    end
  end

  def filtered_records(records, record_per_page, current_page)
    effective_page = effective_page(records.count, record_per_page, current_page)
    records.slice(record_per_page * (effective_page - 1), record_per_page)
  end

  def div_pager(path, total_record, record_per_page, current_page)
    effective_page = effective_page(total_record, record_per_page, current_page)
    content_tag(:div, class: 'row mt-4 justify-content-md-center align-items-center') do
      concat(
        button_to(
          '<< 最初へ', path,
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { page: min_page },
            disabled: effective_page == min_page,
          }
        ),
      )
      concat(
        button_to(
          '< 前へ', path,
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { page: effective_page - 1 },
            disabled: effective_page == min_page,
          }
        ),
      )
      concat(
        content_tag(
          :div, "#{effective_page}/#{max_page(total_record, record_per_page)}",
          { class: 'm-0 col-lg-2 text-center h3' }
        ),
      )
      concat(
        button_to(
          '次へ >', path,
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { page: effective_page + 1 },
            disabled: effective_page == max_page(total_record, record_per_page),
          }
        ),
      )
      concat(
        button_to(
          '最後へ >>', path,
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { page: max_page(total_record, record_per_page) },
            disabled: effective_page == max_page(total_record, record_per_page),
          }
        ),
      )
    end
  end
end
