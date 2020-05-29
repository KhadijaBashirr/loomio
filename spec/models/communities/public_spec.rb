require 'rails_helper'

 describe Communities::Public do
   let(:community) { Communities::Public.new }
   let(:user) { create :user }
   let(:visitor) { create :visitor }

   describe 'includes?' do
     it 'returns true for registered users' do
       expect(community.includes?(user)).to eq true
     end

     it 'returns true for visitors' do
       expect(community.includes?(visitor)).to eq true
     end
   end

 end
