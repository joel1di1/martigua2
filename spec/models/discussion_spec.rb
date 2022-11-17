require 'rails_helper'

RSpec.describe Discussion, type: :model do
  it { is_expected.to belong_to :section }

end
