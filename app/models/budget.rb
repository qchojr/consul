class Budget < ActiveRecord::Base

  include Measurable

  VALID_PHASES = %w(accepting reviewing selecting valuating balloting reviewing_ballots finished).freeze
  CURRENCY_SYMBOLS = %w(€ $ £ ¥).freeze

  validates :name, presence: true
  validates :phase, inclusion: { in: VALID_PHASES }
  validates :currency_symbol, presence: true

  has_many :investments, dependent: :destroy
  has_many :ballots, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :headings, through: :groups

  before_validation :sanitize_descriptions

  scope :on_hold,   -> { where(phase: %w(reviewing valuating reviewing_ballots")) }
  scope :accepting, -> { where(phase: "accepting") }
  scope :reviewing, -> { where(phase: "reviewing") }
  scope :selecting, -> { where(phase: "selecting") }
  scope :valuating, -> { where(phase: "valuating") }
  scope :balloting, -> { where(phase: "balloting") }
  scope :reviewing_ballots, -> { where(phase: "reviewing_ballots") }
  scope :finished,  -> { where(phase: "finished") }

  scope :current,   -> { where.not(phase: "finished") }

  def description
    self.send("description_#{self.phase}").try(:html_safe)
  end

  def accepting?
    phase == "accepting"
  end

  def reviewing?
    phase == "reviewing"
  end

  def selecting?
    phase == "selecting"
  end

  def valuating?
    phase == "valuating"
  end

  def balloting?
    phase == "balloting"
  end

  def reviewing_ballots?
    phase == "reviewing_ballots"
  end

  def finished?
    phase == "finished"
  end

  def on_hold?
    reviewing? || valuating? || reviewing_ballots?
  end

  def current?
    !finished?
  end

  def heading_price(heading)
    heading_ids.include?(heading.id) ? heading.price : -1
  end

  def translated_phase
    I18n.t "budget.phase.#{phase}"
  end

  def formatted_amount(amount)
    ActionController::Base.helpers.number_to_currency(amount,
                                                      precision: 0,
                                                      locale: I18n.default_locale,
                                                      unit: currency_symbol)
  end

  def formatted_heading_price(heading)
    formatted_amount(heading_price(heading))
  end

  def formatted_heading_amount_spent(heading)
    formatted_amount(amount_spent(heading))
  end

  private

    def sanitize_descriptions
      s = WYSIWYGSanitizer.new
      VALID_PHASES.each do |phase|
        sanitized = s.sanitize(self.send("description_#{phase}"))
        self.send("description_#{phase}=", sanitized)
      end
    end
end

