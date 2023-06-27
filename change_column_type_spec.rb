# frozen_string_literal: true

# TODO: remove this test, since it will be of
# limited value once the migration has been run

require 'rails_helper'
require 'rake'

Rails.application.load_tasks
require Rails.root.join('db', 'migrate', '20230627193346_convert_travel_category_to_varchar.rb')

RSpec.describe ConvertTravelCategoryToVarchar do
  self.use_transactional_tests = false
  before do
    system({'RAILS_ENV' => 'test' }, 'rake db:seed:replant')
    rollback_described_migration
  end
  it 'allows us to enter the new categories' do
    run_described_migration
    request = FactoryBot.create :travel_request
    request.travel_category = 'acquisitions'
    expect { request.save }.not_to raise_error
  end
  it 'does not lose any rows marked professional development' do
    request = FactoryBot.create :travel_request, travel_category: 'professional_development'
    request.save
    expect { run_described_migration }.not_to change { TravelRequest.where(travel_category: 'professional_development').count }
  end
  it 'does not lose any rows marked business' do
    request = FactoryBot.create :travel_request, travel_category: 'business'
    request.save
    expect { run_described_migration }.not_to change { TravelRequest.where(travel_category: 'business').count }
  end
end

def run_described_migration
  system({ 'VERSION' => '20230627193346',
           'RAILS_ENV' => 'test' },
    'rake db:migrate:up')
end

def rollback_described_migration
  system({ 'VERSION' => '20230627193346',
           'RAILS_ENV' => 'test' },
          'rake db:migrate:down')
  Request.reset_column_information
end
