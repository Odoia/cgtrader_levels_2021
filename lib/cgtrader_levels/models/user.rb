class CgtraderLevels::User < ActiveRecord::Base
  attr_reader :level

  after_initialize do
    self.reputation = 0

    matching_level = CgtraderLevels::Level.find_by(experience: reputation)

    if matching_level
      self.level_id = matching_level.id
      @level = matching_level
    end
  end

  after_update :set_new_level

  private

  def set_new_level
    matching_level = CgtraderLevels::Level.find_by(experience: reputation)

    if matching_level
      update_privileges if level.experience < reputation

      self.level_id = matching_level.id
      @level = matching_level
    end
  end

  def update_privileges
    coins_reward
    tax_reduce
  end

  def coins_reward
    return unless coin_reward_by_reputation_hash[reputation]

    self.coins += coin_reward_by_reputation_hash[reputation]
  end

  def coin_reward_by_reputation_hash
    {
      10 => 7
    }
  end

  def tax_reduce
    return unless tax_reduce_by_reputation_hash[reputation]

    reduce_tax = tax_reduce_by_reputation_hash[reputation]
    result = ((1 - reduce_tax) * tax)

    self.tax = result
  end

  def tax_reduce_by_reputation_hash
    {
      10 => 0.01
    }
  end
end
