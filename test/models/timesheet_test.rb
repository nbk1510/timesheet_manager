require 'test_helper'

class TimesheetsControllerTest < ActiveSupport::TestCase
  test 'Creating new timesheet' do
    timesheet1 = Timesheet.new(date: '2019-04-17'.to_date, start_time: '04:00', end_time: '21:30')
    timesheet1.save
    assert timesheet1.calculated_pay == 451.0, 'Created a valid timesheet'

    timesheet2 = Timesheet.new(date: '2019-04-16'.to_date, start_time: '12:00', end_time: '20:15')
    timesheet2.save
    assert timesheet2.calculated_pay == 238.75, 'Created a valid timesheet'

    timesheet3 = Timesheet.new(date: '2019-04-20'.to_date, start_time: '15:30', end_time: '20:00')
    timesheet3.save

    assert timesheet3.calculated_pay == 211.5, 'Created a valid timesheet'
  end
end
