# frozen_string_literal: true

RSpec.describe FfhbService do
  let(:ffhb_instance) { FfhbService.instance }

  before { mock_ffhb }

  describe '#get_pool_as_json' do
    subject(:pool_as_json) { ffhb_instance.get_pool_as_json(110_562) }

    it { expect(pool_as_json).to be_a(Hash) }
    it { expect(pool_as_json['journee']).to be(5) }

    it { expect { ffhb_instance.get_pool_as_json(123) }.to raise_error(RuntimeError, 'Could not find pool with id 123') }
  end

  describe '#build_specific_calendar' do
    subject(:calendar) { ffhb_instance.build_specific_calendar(ffhb_instance.get_pool_as_json(110_562)) }

    it { expect(calendar).to be_a(Calendar) }
    it { expect(calendar.days.size).to be(22) }
    it { expect(calendar.days[1]).to be_a(Day) }
    it { expect(calendar.days[1].name).to eq('Journée 2') }
    it { expect(calendar.days[1].period_start_date).to eq(Date.new(2022, 10, 1)) }
    it { expect(calendar.days[1].period_end_date).to eq(Date.new(2022, 10, 2)) }
  end
end
