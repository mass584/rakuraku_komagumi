module TermHelper
  def terms_table_content(terms)
    {
      attributes: %w[スケジュール名 種別 年度 開始日 終了日 編集 選択],
      records: terms.map do |term|
        term_table_record(term)
      end,
    }
  end

  def term_table_record(term)
    {
      id: term.id,
      tds: [
        term.name,
        term.term_type_i18n,
        "#{term.year}年度",
        "#{l term.begin_at}",
        "#{l term.end_at}",
        content_tag(:div) do
          render partial: 'terms/edit', locals: { term: term }
        end,
        content_tag(:div) do
          link_to '選択', term_path(term, {term_id: term.id}), { class: 'btn btn-dark' }
        end,
      ],
    }
  end
end
