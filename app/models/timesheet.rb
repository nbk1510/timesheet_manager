class Timesheet < ApplicationRecord
  # CONSTANTS
  REGEX = /\A(0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])\z/.freeze

  # VALIDATIONS
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true

  validates :start_time, format: { with: REGEX, message: 'Format should be hh:mm!' }
  validates :end_time, format: { with: REGEX, message: 'Format should be hh:mm!' }
  validate :check_validity, if: -> { errors.empty? }

  # CALLBACKS
  before_save :calculate_pay

  def check_validity
    # check end time should be after start time
    errors.add(:base, 'End time should be after Start time!') if full_end_time <= full_start_time

    # check for overlapping times
    Timesheet.where(date: date) do |t|
      if full_start_time.between?(t.full_start_time, t.full_end_time) || full_end_time.between?(t.full_start_time, t.full_end_time) ||
         t.full_start_time.between?(full_start_time, full_end_time) || t.full_end_time.between?(full_start_time, full_end_time)
        errors.add(:base, 'There is a timesheet overlapping with this time values!')
        break
      end
    end
  end

  def full_start_time
    "#{date.strftime('%F')} #{start_time}".to_datetime
  end

  def full_end_time
    "#{date.strftime('%F')} #{end_time}".to_datetime
  end

  def start_time_float
    convert_time_to_usable_float(start_time)
  end

  def end_time_float
    convert_time_to_usable_float(end_time)
  end

  private

  # - Monday, Wednesday, Friday
  #   - 7am - 7pm: $22/hour
  #   - Outside: $34/hour
  # - Tuesday, Thursday
  #   - 5am - 5pm: $25/hour
  #   - Outside: $35/hour
  # - Weekend
  #   - Always $47/hour

  def calculate_pay
    self.calculated_pay = case date.wday
                          when 6, 0
                            time_range = {
                              (0...24) => 47
                            }
                            money_in_time_range(time_range)
                          when 1, 3, 5
                            time_range = {
                              (0...7) => 34,
                              (7...19) => 22,
                              (19...24) => 34
                            }
                            money_in_time_range(time_range)
                          when 2, 4
                            time_range = {
                              (0...5) => 35,
                              (5...17) => 25,
                              (17...24) => 35
                            }
                            money_in_time_range(time_range)
                          end
  end

  def money_in_time_range(time_range)
    calculated_money = 0
    left = right = 0
    time_range.each do |t, r|
      left = if t.include?(start_time_float)
               start_time_float
             elsif start_time_float > t.first && start_time_float > t.last
               t.last
             else
               t.first
             end

      right = if t.include?(end_time_float)
                end_time_float
              elsif end_time_float > t.first && end_time_float > t.last
                t.last
              else
                t.first
              end

      total_time = right - left

      calculated_money += total_time * r
    end
    calculated_money.to_f
  end

  def convert_time_to_usable_float(string)
    hour = string.to_datetime.hour
    minute = string.to_datetime.minute.to_f / 60
    (hour + minute).to_f
  end
end
