class SubjectTerm < ApplicationRecord
  belongs_to :subject
  belongs_to :term

  def self.bulk_create(term)
    term.room.exist_subjects.each do |subject|
      create(
        term_id: term.id,
        subject_id: subject.id,
      )
    end
  end

  def save_with_contract
    Contract.bulk_create_for_subject(subject, term)
    save
  end
end
