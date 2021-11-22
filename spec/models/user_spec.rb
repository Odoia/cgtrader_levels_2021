require 'spec_helper'

describe CgtraderLevels::User, type: :model do

  let(:level1) { CgtraderLevels::Level.create!(experience: 0, title: 'First level') }
  let(:level2) { CgtraderLevels::Level.create!(experience: 10, title: 'Second level') }
  let(:level3) { CgtraderLevels::Level.create!(experience: 13, title: 'Third level') }
  let(:user) { CgtraderLevels::User.create! }

  context 'new user' do
    before do
      level1
    end

    it 'has 0 reputation points' do
      user = CgtraderLevels::User.new
      expect(user.reputation).to eq(0)
    end

    it "has assigned 'First level'" do
      user = CgtraderLevels::User.new

      expect(user.level).to eq(level1)
    end
  end

  context 'level up' do
    before do
      level1
      level2
      level3
    end

    it "level ups from 'First level' to 'Second level'" do
      expect { user.update_attribute(:reputation, 10) }
        .to change { user.reload.level }.from(level1).to(level2)
    end

    it "level ups from 'First level' to 'Third level'" do
      expect { user.update_attribute(:reputation, 13) }
        .to change { user.reload.level }.from(level1).to(level3)
    end
  end

  context 'level up bonuses & privileges' do
    context 'when user increase reputation' do
      before do
        level1
        level2
      end

      it 'must gives 7 coins to user' do
        user = CgtraderLevels::User.create!(coins: 1)

        expect { user.update_attribute(:reputation, 10) }
          .to change { user.coins }.from(1).to(8)
      end

      it 'must reduces tax rate by 1' do
        expect { user.update_attribute(:reputation, 10) }
          .to change { user.tax }.from(30).to(29.7)
      end

      context 'when the reputation has no bonus' do
        it 'number of coins must not be changed' do
          expect { user.update_attribute(:reputation, 13) }
            .to_not change { user.coins }
        end

        it 'tax rate must not be changed' do
          expect { user.update_attribute(:reputation, 13) }
            .to_not change { user.tax }
        end
      end
    end

    context 'when user reduce reputation' do
      it 'number of coins must not be changed' do
        user = CgtraderLevels::User.create!(reputation: 3)
        expect { user.update_attribute(:reputation, 0) }
          .to_not change { user.coins }
      end

      it 'tax rate must not be changed' do
        user = CgtraderLevels::User.create!(reputation: 3)
        expect { user.update_attribute(:reputation, 0) }
          .to_not change { user.tax }
      end
    end
  end
end
