module TermHelper
  def terms_table_content(terms)
    {
      attributes: %w[スケジュール名 種別 開始日 終了日 編集],
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
        "#{l term.begin_at}",
        "#{l term.end_at}",
        content_tag(:div) { link_to '開く', term_path(term, {term_id: term.id}) },
      ],
    }
  end
end
