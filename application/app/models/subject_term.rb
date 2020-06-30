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

  def self.additional_create(subject, term)
    new(
      subject_id: subject.id,
      term_id: term.id,
    ).save && Contract.bulk_create_for_subject(
      subject,
      term,
    )
  end
end
