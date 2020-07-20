class Contract < ApplicationRecord
  belongs_to :term
  belongs_to :student_term
  belongs_to :subject_term
  belongs_to :teacher_term, optional: true
  has_many :pieces, dependent: :destroy
  validate :can_update_teacher_term_id, on: :update, if: :will_save_change_to_teacher_term_id?
  validate :can_update_count, on: :update, if: :will_save_change_to_count?
  after_save :create_or_destroy_pieces

  def self.get_contracts(term_id)
    where(term_id: term_id).reduce({}) do |accu, item|
      accu.deep_merge({
        item.student_term_id => {
          item.subject_term_id => item,
        },
      })
    end
  end

  def self.bulk_create(term)
    term.student_terms.each do |student_term|
      term.subject_terms.each do |subject_term|
        create_with_default(student_term, subject_term, term)
      end
    end
  end

  def self.bulk_create_for_student(student_term, term)
    term.subject_terms.each do |subject_term|
      create_with_default(student_term, subject_term, term)
    end
  end

  def self.bulk_create_for_subject(subject_term, term)
    term.student_terms.each do |student_term|
      create_with_default(student_term, subject_term, term)
    end
  end

  def self.create_with_default(student_term, subject_term, term)
    is_subscribed = StudentSubject.exists?(
      student_id: student_term.student.id,
      subject_id: subject_term.subject.id,
    )
    create(
      term_id: term.id,
      student_term_id: student_term.id,
      subject_term_id: subject_term.id,
      count: is_subscribed ? 1 : 0,
    )
  end

  private

  def can_update_teacher_term_id
    assigned_pieces = pieces.where.not(seat_id: nil)
    if assigned_pieces.exists?
      errors[:base] << '予定が決定済の授業があるため、担任の先生を変更することが出来ません。
        変更したい場合は、この画面で該当する授業を削除し、再設定を行ってください。'
    end
  end

  def can_update_count
    unassigned_pieces = pieces.where(seat_id: nil)
    if (count_in_database - count) > unassigned_pieces.count
      errors[:base] << '授業回数を、予定決定済の授業数よりも少なくすることは出来ません。
        少なくしたい場合は、予定編集画面で決定済の授業を未決定に戻してください。'
    end
  end

  def create_or_destroy_pieces
    if count > count_before_last_save.to_i
      (count - count_before_last_save.to_i).times do
        Piece.create(term_id: term_id, contract_id: id)
      end
    elsif count < count_before_last_save.to_i
      (count_before_last_save.to_i - count).times do
        pieces.find_by(seat_id: nil).destroy
      end
    end
  end
end
